require 'test_helper'
require 'util'
require 'socket'
require 'net/http'

class IdempotencyTest < SeatsioTestClient
  def test_same_idempotency_key_replays_the_response
    client = client_of(create_test_user(idempotencyEnabled: true))
    chart_key = create_test_chart
    keyed_client = client.with_idempotency_key(SecureRandom.uuid)

    first = keyed_client.events.create(chart_key: chart_key)
    second = keyed_client.events.create(chart_key: chart_key)

    assert_equal(first.id, second.id)
    assert_equal(first.key, second.key)
  end

  def test_same_idempotency_key_with_a_different_request_is_rejected
    client = client_of(create_test_user(idempotencyEnabled: true))
    chart_key = create_test_chart
    keyed_client = client.with_idempotency_key(SecureRandom.uuid)
    keyed_client.events.create(chart_key: chart_key)

    error = assert_raises(Seatsio::Exception::SeatsioException) do
      keyed_client.events.create(chart_key: chart_key, event_key: "anotherEvent")
    end

    assert_includes(error.message, "IDEMPOTENCY_KEY_REUSED")
  end

  def test_idempotency_key_is_ignored_when_not_enabled_for_the_company
    chart_key = create_test_chart
    keyed_client = @seatsio.with_idempotency_key(SecureRandom.uuid)

    first = keyed_client.events.create(chart_key: chart_key)
    second = keyed_client.events.create(chart_key: chart_key)

    refute_equal(first.id, second.id)
  end

  def test_supplied_idempotency_key_is_available_on_a_failed_request
    client = client_of(create_test_user(idempotencyEnabled: true))
    key = SecureRandom.uuid

    error = assert_raises(Seatsio::Exception::SeatsioException) do
      client.with_idempotency_key(key).events.create(chart_key: "unknownChart")
    end

    assert_equal(key, error.idempotency_key)
  end

  def test_generated_idempotency_key_is_available_on_a_failed_request
    client = client_of(create_test_user(idempotencyEnabled: true))

    error = assert_raises(Seatsio::Exception::SeatsioException) do
      client.events.create(chart_key: "unknownChart")
    end

    refute_nil(error.idempotency_key)
  end

  def test_retry_after_a_lost_response_creates_one_event
    company = create_test_user(idempotencyEnabled: true)
    @user = company['admin']
    chart_key = create_test_chart
    proxy = ProxyThatForwardsButDropsTheFirstResponse.new(BASE_URL)
    client = Seatsio::Client.new(Seatsio::Region.new(proxy.url), @user['secretKey'])
    client.retry_non_idempotent_requests = true

    event = client.events.create(chart_key: chart_key)

    all = client_of(company).events.list.to_a
    assert_equal(1, all.length)
    assert_equal(event.id, all.first.id)
  ensure
    proxy&.close
  end

  private

  def client_of(company)
    @user = company['admin']
    test_client(@user['secretKey'], nil)
  end

  class ProxyThatForwardsButDropsTheFirstResponse
    def initialize(target)
      @target = URI(target)
      @server = TCPServer.new("127.0.0.1", 0)
      @requests = 0
      @thread = Thread.new { loop { handle(@server.accept) } }
    end

    def url
      "http://127.0.0.1:#{@server.addr[1]}"
    end

    def close
      @thread.kill
      @server.close
    end

    private

    def handle(socket)
      method, path = socket.gets.split(" ")
      headers = {}
      while (line = socket.gets) && line != "\r\n"
        name, value = line.split(":", 2)
        headers[name] = value.strip
      end
      body = socket.read(headers.find { |name, _| name.casecmp?("Content-Length") }&.last.to_i)
      response = forward(method, path, headers, body)
      @requests += 1
      unless @requests == 1
        socket.write("HTTP/1.1 #{response.code} #{response.message}\r\n")
        socket.write("Content-Type: #{response['Content-Type']}\r\n") if response['Content-Type']
        socket.write("Content-Length: #{response.body.to_s.bytesize}\r\nConnection: close\r\n\r\n#{response.body}")
      end
    ensure
      socket.close
    end

    def forward(method, path, headers, body)
      request = Net::HTTPGenericRequest.new(method, !body.to_s.empty?, true, path)
      headers.each { |name, value| request[name] = value unless name.casecmp?("Host") }
      request.body = body unless body.to_s.empty?
      Net::HTTP.start(@target.host, @target.port, use_ssl: @target.scheme == "https") { |http| http.request(request) }
    end
  end
end
