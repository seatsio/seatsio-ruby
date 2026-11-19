require 'test_helper'
require 'util'

class IdempotencyKeyTest < Minitest::Test
  UUID_V4 = /\A\h{8}-\h{4}-4\h{3}-[89ab]\h{3}-\h{12}\z/
  BASE = "https://seatsio.test"
  URL = "#{BASE}/test-endpoint"
  WRITE_METHODS = [:post, :put, :delete]

  def test_writes_send_a_v4_idempotency_key
    WRITE_METHODS.each do |method|
      keys = []
      stub_recording_keys(keys, method, URL).to_return(status: 204)

      http_client.execute(method, "test-endpoint", {})

      assert_equal(1, keys.length, method)
      assert_match(UUID_V4, keys.first, method)
    end
  end

  def test_gets_send_no_idempotency_key
    keys = []
    stub_recording_keys(keys, :get, URL).to_return(status: 204)

    http_client.get("test-endpoint")

    assert_equal([nil], keys)
  end

  def test_generates_a_different_key_for_each_request
    keys = []
    stub_recording_keys(keys, :post, URL).to_return(status: 204)
    client = http_client

    client.post("test-endpoint")
    client.post("test-endpoint")

    assert_equal(2, keys.uniq.length)
  end

  def test_retries_after_429_reuse_the_same_key
    keys = []
    stub_recording_keys(keys, :post, URL).to_return({ status: 429 }, { status: 204 })

    http_client(max_retries: 5).post("test-endpoint")

    assert_equal(2, keys.length)
    assert_match(UUID_V4, keys.first)
    assert_equal(keys.first, keys.last)
  end

  def test_retries_key_in_use_conflict_with_the_same_key
    keys = []
    stub_recording_keys(keys, :post, URL).to_return(api_error(409, "IDEMPOTENCY_KEY_IN_USE"), { status: 204 })

    http_client(max_retries: 5).post("test-endpoint")

    assert_equal(2, keys.length)
    assert_equal(keys.first, keys.last)
  end

  def test_does_not_retry_other_conflicts
    stub_request(:post, URL).to_return(api_error(409, "SOMETHING_ELSE"))

    error = assert_raises(Seatsio::Exception::SeatsioException) { http_client(max_retries: 5).post("test-endpoint") }

    assert_requested(:post, URL, times: 1)
    assert_match(UUID_V4, error.idempotency_key)
  end

  def test_does_not_retry_conflict_without_an_error_code
    ['{"errors":[]}', '{}', 'not json', ''].each do |body|
      WebMock.reset!
      stub_request(:post, URL).to_return(status: 409, headers: { 'Content-Type' => 'application/json' }, body: body)

      assert_raises(Seatsio::Exception::SeatsioException) { http_client(max_retries: 5).post("test-endpoint") }

      assert_requested(:post, URL, times: 1)
    end
  end

  def test_key_in_use_error_is_raised_when_retries_run_out
    keys = []
    stub_recording_keys(keys, :post, URL).to_return(api_error(409, "IDEMPOTENCY_KEY_IN_USE"))

    error = assert_raises(Seatsio::Exception::SeatsioException) { http_client(max_retries: 2).post("test-endpoint") }

    assert_equal(3, keys.length)
    assert_equal(1, keys.uniq.length)
    assert_equal(keys.first, error.idempotency_key)
  end

  def test_does_not_retry_writes_by_default_when_connection_fails
    WRITE_METHODS.each do |method|
      stub_request(method, URL).to_raise(EOFError)

      assert_raises(Seatsio::Exception::SeatsioException) { http_client(max_retries: 5).execute(method, "test-endpoint", {}) }

      assert_requested(method, URL, times: 1)
    end
  end

  def test_retries_writes_with_the_same_key_when_enabled
    WRITE_METHODS.each do |method|
      keys = []
      stub_recording_keys(keys, method, URL).to_raise(EOFError).then.to_return(status: 204)
      client = http_client(max_retries: 5)
      client.retry_non_idempotent_requests = true

      client.execute(method, "test-endpoint", {})

      assert_equal(2, keys.length, method)
      assert_equal(keys.first, keys.last, method)
    end
  end

  def test_does_not_retry_writes_after_retries_are_disabled_again
    stub_request(:post, URL).to_raise(EOFError)
    client = http_client(max_retries: 5)
    client.retry_non_idempotent_requests = true
    client.retry_non_idempotent_requests = false

    assert_raises(Seatsio::Exception::SeatsioException) { client.post("test-endpoint") }

    assert_requested(:post, URL, times: 1)
  end

  def test_does_not_retry_gets_when_connection_fails
    stub_request(:get, URL).to_raise(EOFError)
    client = http_client(max_retries: 5)
    client.retry_non_idempotent_requests = true

    assert_raises(RestClient::ServerBrokeConnection) { client.get("test-endpoint") }

    assert_requested(:get, URL, times: 1)
  end

  def test_retries_timed_out_writes_with_the_same_key_when_enabled
    keys = []
    stub_recording_keys(keys, :post, URL).to_timeout.then.to_return(status: 204)
    client = http_client(max_retries: 5)
    client.retry_non_idempotent_requests = true

    client.post("test-endpoint")

    assert_equal(2, keys.length)
    assert_equal(keys.first, keys.last)
  end

  def test_does_not_retry_timed_out_gets
    stub_request(:get, URL).to_timeout
    client = http_client(max_retries: 5)
    client.retry_non_idempotent_requests = true

    error = assert_raises(Seatsio::Exception::SeatsioException) { client.get("test-endpoint") }

    assert_equal("Timeout ERROR", error.message)
    assert_requested(:get, URL, times: 1)
  end

  def test_connection_error_is_raised_when_retries_of_writes_run_out
    keys = []
    stub_recording_keys(keys, :post, URL).to_raise(EOFError)
    client = http_client(max_retries: 2)
    client.retry_non_idempotent_requests = true

    error = assert_raises(Seatsio::Exception::SeatsioException) { client.post("test-endpoint") }

    assert_equal(3, keys.length)
    assert_equal(1, keys.uniq.length)
    assert_equal(keys.first, error.idempotency_key)
    assert_instance_of(RestClient::ServerBrokeConnection, error.cause)
  end

  def test_retries_read_timeouts_of_writes_only_once
    keys = []
    stub_recording_keys(keys, :post, URL).to_raise(Net::ReadTimeout)
    client = http_client(max_retries: 5)
    client.retry_non_idempotent_requests = true

    error = assert_raises(Seatsio::Exception::SeatsioException) { client.post("test-endpoint") }

    assert_equal(2, keys.length)
    assert_equal(keys.first, keys.last)
    assert_equal(keys.first, error.idempotency_key)
    assert_instance_of(RestClient::Exceptions::ReadTimeout, error.cause)
  end

  def test_a_read_timeout_does_not_use_up_the_retries_of_other_connection_errors
    keys = []
    stub_recording_keys(keys, :post, URL).to_raise(EOFError).then.to_raise(Net::ReadTimeout).then.to_raise(EOFError).then.to_return(status: 204)
    client = http_client(max_retries: 5)
    client.retry_non_idempotent_requests = true

    client.post("test-endpoint")

    assert_equal(4, keys.length)
  end

  def test_retries_of_writes_after_connection_errors_wait_with_jitter
    stub_request(:post, URL).to_raise(EOFError)
    waits = []
    client = record_sleeps(http_client(max_retries: 5), waits)
    client.retry_non_idempotent_requests = true

    assert_raises(Seatsio::Exception::SeatsioException) { client.post("test-endpoint") }

    assert_equal(5, waits.length)
    [0.4, 0.8, 1.6, 3.2, 6.4].zip(waits).each do |backoff, wait|
      assert_operator(wait, :>=, backoff / 2)
      assert_operator(wait, :<=, backoff)
    end
  end

  def test_retries_after_429_wait_without_jitter
    stub_request(:post, URL).to_return(status: 429)
    waits = []
    client = record_sleeps(http_client(max_retries: 2), waits)

    assert_raises(Seatsio::Exception::RateLimitExceededException) { client.post("test-endpoint") }

    assert_equal([0.4, 0.8], waits)
  end

  def test_enabling_retries_of_writes_applies_to_copies_with_a_key
    stub_request(:post, URL).to_raise(EOFError).then.to_return(status: 204)
    client = http_client(max_retries: 5)
    keyed = record_sleeps(client.with_idempotency_key(SecureRandom.uuid), [])

    client.retry_non_idempotent_requests = true
    keyed.post("test-endpoint")

    assert_requested(:post, URL, times: 2)
  end

  def test_enabling_retries_of_writes_on_a_copy_with_a_key_applies_to_the_original_client
    stub_request(:post, URL).to_raise(EOFError).then.to_return(status: 204)
    client = http_client(max_retries: 5)

    client.with_idempotency_key(SecureRandom.uuid).retry_non_idempotent_requests = true
    client.post("test-endpoint")

    assert_requested(:post, URL, times: 2)
  end

  def test_seatsio_client_shares_retries_of_writes_with_copies_with_a_key
    keys = []
    stub_recording_keys(keys, :post, "#{BASE}/hold-tokens").to_raise(EOFError).then.to_return(hold_token_response)
    client = seatsio_client
    keyed = client.with_idempotency_key(SecureRandom.uuid)

    client.retry_non_idempotent_requests = true
    keyed.hold_tokens.create

    assert_equal(2, keys.length)
  end

  def test_connection_errors_of_writes_carry_the_key_and_the_original_error
    {
      EOFError => RestClient::ServerBrokeConnection,
      Errno::ECONNRESET => Errno::ECONNRESET,
      OpenSSL::SSL::SSLError => OpenSSL::SSL::SSLError
    }.each do |raised, cause|
      WebMock.reset!
      stub_request(:post, URL).to_raise(raised)

      error = assert_raises(Seatsio::Exception::SeatsioException) { http_client.post("test-endpoint") }

      assert_match(UUID_V4, error.idempotency_key)
      assert_instance_of(cause, error.cause)
      assert_equal("Error while executing POST test-endpoint: #{error.cause.message}", error.message)
    end
  end

  def test_connection_refused_on_a_write_carries_the_key
    client = Seatsio::HttpClient.new("aSecretKey", nil, "http://localhost:1", 0)

    error = assert_raises(Seatsio::Exception::SeatsioException) { client.post("anything") }

    assert_match(UUID_V4, error.idempotency_key)
    assert_kind_of(SystemCallError, error.cause)
  end

  def test_timeouts_of_writes_carry_the_key
    stub_request(:post, URL).to_timeout

    error = assert_raises(Seatsio::Exception::SeatsioException) { http_client.post("test-endpoint") }

    assert_equal("Timeout ERROR", error.message)
    assert_match(UUID_V4, error.idempotency_key)
  end

  def test_connection_errors_of_gets_are_not_wrapped
    stub_request(:get, URL).to_raise(Errno::ECONNRESET)

    assert_raises(Errno::ECONNRESET) { http_client.get("test-endpoint") }
  end

  def test_error_responses_of_writes_carry_the_key
    [
      api_error(400, "SOME_ERROR"),
      { status: 500, headers: { 'Content-Type' => 'application/json' }, body: 'not json' },
      { status: 500, headers: { 'Content-Type' => 'application/json' }, body: '{}' },
      { status: 500, headers: { 'Content-Type' => 'text/plain' }, body: 'oops' },
      { status: 200, headers: { 'Content-Type' => 'text/html' }, body: '<html>proxy</html>' }
    ].each do |response|
      WebMock.reset!
      keys = []
      stub_recording_keys(keys, :post, URL).to_return(response)

      error = assert_raises(Seatsio::Exception::SeatsioException) { http_client.post("test-endpoint") }

      assert_equal(keys.first, error.idempotency_key, response.inspect)
    end
  end

  def test_error_responses_of_gets_without_an_error_code_raise_a_seatsio_exception
    ['{}', '{"errors":[]}', 'not json'].each do |body|
      WebMock.reset!
      stub_request(:get, URL).to_return(status: 500, headers: { 'Content-Type' => 'application/json' }, body: body)

      error = assert_raises(Seatsio::Exception::SeatsioException) { http_client.get("test-endpoint") }

      assert_nil(error.idempotency_key)
    end
  end

  def test_best_available_objects_not_found_is_still_recognised
    stub_request(:post, URL).to_return(api_error(400, "BEST_AVAILABLE_OBJECTS_NOT_FOUND"))

    assert_raises(Seatsio::Exception::BestAvailableObjectsNotFoundException) { http_client.post("test-endpoint") }
  end

  def test_supplied_key_is_sent_and_survives_a_retry
    key = SecureRandom.uuid
    keys = []
    stub_recording_keys(keys, :post, URL).to_return({ status: 429 }, { status: 204 }, { status: 204 })
    client = http_client(max_retries: 5).with_idempotency_key(key)

    client.post("test-endpoint")
    client.post("test-endpoint")

    assert_equal([key, key, key], keys)
  end

  def test_supplied_key_must_be_a_v4_uuid
    [nil, "", "not a uuid", "6ba7b810-9dad-11d1-80b4-00c04fd430c8", "00000000-0000-0000-0000-000000000000"].each do |key|
      assert_raises(ArgumentError, key.inspect) { http_client.with_idempotency_key(key) }
    end
  end

  def test_with_idempotency_key_does_not_affect_the_original_client
    keys = []
    stub_recording_keys(keys, :post, URL).to_return(status: 204)
    client = http_client
    client.with_idempotency_key(SecureRandom.uuid)

    client.post("test-endpoint")
    client.post("test-endpoint")

    assert_equal(2, keys.uniq.length)
  end

  def test_seatsio_client_with_idempotency_key_sends_the_key_from_every_sub_client
    key = SecureRandom.uuid
    hold_token_keys = []
    stub_recording_keys(hold_token_keys, :post, "#{BASE}/hold-tokens").to_return(hold_token_response)
    season_keys = []
    stub_recording_keys(season_keys, :post, "#{BASE}/seasons").to_return(json_response({ key: "aSeason" }))
    client = seatsio_client.with_idempotency_key(key)

    client.hold_tokens.create
    client.seasons.create(chart_key: "aChart")

    assert_equal([key], hold_token_keys)
    assert_equal([key], season_keys)
  end

  def test_seatsio_client_with_idempotency_key_does_not_affect_the_original_client
    key = SecureRandom.uuid
    keys = []
    stub_recording_keys(keys, :post, "#{BASE}/hold-tokens").to_return(hold_token_response)
    client = seatsio_client
    client.with_idempotency_key(key)

    client.hold_tokens.create

    refute_equal(key, keys.first)
  end

  def test_seatsio_client_can_enable_retries_of_writes
    keys = []
    stub_recording_keys(keys, :post, "#{BASE}/hold-tokens").to_raise(EOFError).then.to_return(hold_token_response)
    client = seatsio_client
    client.retry_non_idempotent_requests = true

    client.hold_tokens.create

    assert_equal(2, keys.length)
    assert_equal(keys.first, keys.last)
  end

  private

  def http_client(max_retries: 0)
    record_sleeps(Seatsio::HttpClient.new("aSecretKey", nil, BASE, max_retries), [])
  end

  def seatsio_client
    Seatsio::Client.new(Seatsio::Region.new(BASE), "aSecretKey", nil, 5)
  end

  def stub_recording_keys(keys, method, url)
    stub_request(method, url).with { |request| keys << request.headers["Idempotency-Key"] }
  end

  def api_error(status, code)
    { status: status, headers: { 'Content-Type' => 'application/json' }, body: { errors: [{ code: code, message: "an error" }] }.to_json }
  end

  def hold_token_response
    json_response({ holdToken: "abc", expiresAt: "2026-01-01T00:00:00Z", expiresInSeconds: 900 })
  end

  def record_sleeps(client, waits)
    client.define_singleton_method(:sleep) { |seconds| waits << seconds }
    client
  end

  def json_response(body)
    { status: 200, headers: { 'Content-Type' => 'application/json' }, body: body.to_json }
  end
end
