require 'test_helper'
require 'util'

class ExponentialBackoffTest < SeatsioTestClient
  def test_aborts_eventually_if_server_keeps_returning_429
    start = Time.now
    begin
      client = Seatsio::HttpClient.new("aSecretKey", nil, "https://mockbin.org", 5)
      client.get("bin/0381d6f4-0155-4b8c-937b-73d3d88b2a3f")
      raise "Should have failed"
    rescue Seatsio::Exception::RateLimitExceededException => e
      assert_equal(429, e.message.code)
      wait_time = Time.now.to_i - start.to_i
      assert_between(wait_time, 10, 20)
    end
  end

  def test_aborts_directly_if_server_returns_other_error_than_429
    start = Time.now
    begin
      client = Seatsio::HttpClient.new("aSecretKey", nil, "https://mockbin.org", 5)
      client.get("bin/1eea3aab-2bb2-4f92-99c2-50d942fb6294")
      raise "Should have failed"
    rescue Seatsio::Exception::SeatsioException => e
      assert_equal(400, e.message.code)
      wait_time = Time.now.to_i - start.to_i
      assert_true(wait_time < 2)
    end
  end

  def test_aborts_directly_if_server_returns_429_but_0_max_retries
    start = Time.now
    begin
      client = Seatsio::HttpClient.new("aSecretKey", nil, "https://mockbin.org", 0)
      client.get("bin/0381d6f4-0155-4b8c-937b-73d3d88b2a3f")
      raise "Should have failed"
    rescue Seatsio::Exception::RateLimitExceededException => e
      assert_equal(429, e.message.code)
      wait_time = Time.now.to_i - start.to_i
      assert_true(wait_time < 2)
    end
  end

  def test_returns_successfully_when_server_sends_429_and_then_successful_response
    client = Seatsio::HttpClient.new("aSecretKey", nil, "https://httpbin.org", 5)

    i = 0
    while i < 20
      client.get("/status/429:0.25,204:0.75")
      i += 1
    end
  end
end
