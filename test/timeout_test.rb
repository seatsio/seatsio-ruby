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
end
