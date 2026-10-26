require 'test_helper'
require 'util'

class TimeoutTest < Minitest::Test
  def test_raises_seatsio_exception_on_timeout
    stub_request(:get, "https://api-staging-eu.seatsio.net/test-endpoint")
      .to_timeout

    client = Seatsio::HttpClient.new("aSecretKey", nil, "https://api-staging-eu.seatsio.net", 0)

    assert_raises Seatsio::Exception::SeatsioException do
      client.get("test-endpoint")
    end
  end

  def test_timeout_exception_has_correct_message
    stub_request(:get, "https://api-staging-eu.seatsio.net/test-endpoint")
      .to_timeout

    client = Seatsio::HttpClient.new("aSecretKey", nil, "https://api-staging-eu.seatsio.net", 0)

    error = assert_raises Seatsio::Exception::SeatsioException do
      client.get("test-endpoint")
    end

    assert_equal "Timeout ERROR", error.message
  end

  def test_uses_default_timeouts
    options = captured_request_options(Seatsio::HttpClient.new("aSecretKey", nil, "https://api-staging-eu.seatsio.net", 0))

    assert_equal 10, options[:open_timeout]
    assert_equal 30, options[:read_timeout]
    assert_nil options[:timeout]
  end

  def test_uses_configured_timeouts
    options = captured_request_options(Seatsio::HttpClient.new("aSecretKey", nil, "https://api-staging-eu.seatsio.net", 0, 3, 60))

    assert_equal 3, options[:open_timeout]
    assert_equal 60, options[:read_timeout]
  end

  def test_does_not_retry_on_timeout
    calls = 0
    client = Seatsio::HttpClient.new("aSecretKey", nil, "https://api-staging-eu.seatsio.net", 5)

    with_stubbed_execute(->(_options) { calls += 1; raise RestClient::Exceptions::ReadTimeout }) do
      assert_raises(Seatsio::Exception::SeatsioException) { client.get("test-endpoint") }
    end

    assert_equal 1, calls
  end

  private

  def captured_request_options(client)
    options = nil
    with_stubbed_execute(->(request_options) { options = request_options; "{}" }) do
      client.get("test-endpoint")
    end
    options
  end

  def with_stubbed_execute(implementation)
    original = RestClient::Request.method(:execute)
    RestClient::Request.define_singleton_method(:execute) { |options| implementation.call(options) }
    yield
  ensure
    RestClient::Request.define_singleton_method(:execute, original)
  end
end
