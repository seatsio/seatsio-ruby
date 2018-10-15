require "json"
require "net/http"
require "test_helper"
require 'securerandom'

BASE_URL = "https://api-staging.seatsio.net"

class SeatsioTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user["secretKey"], "https://api-staging.seatsio.net")
  end

  def create_test_user
    post = Net::HTTP.post_form(URI.parse(BASE_URL + "/system/public/users/actions/create-test-user"),{})
    if post.code === "200"
      JSON.parse(post.body)
    else
      raise Exception("Failed to create a test user")
    end
  end

  def create_chart_from_file
    chart_file = File.read(Dir.pwd + "/test/sampleChart.json")
    chart_key = SecureRandom.uuid

    url = BASE_URL + "/system/public/" + @user["designerKey"] + "/charts/" + chart_key
    post = Net::HTTP.post(URI.parse(url), chart_file, {"Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"})

    if post.is_a?(Net::HTTPCreated)
      puts "Chart created"
      chart_key
    else
      raise "Failed to create a chart from file test/sampleChart.json"
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Seatsio::VERSION
  end

  def test_initialize
    assert_instance_of Seatsio::Seatsio, @seatsio
  end

  def test_initialize_charts_client
    assert_instance_of Seatsio::ChartsClient, @seatsio.client.charts
  end

  def test_create_and_get_chart
    chart_key = create_chart_from_file
    assert_kind_of(String, chart_key)

    puts "Retrieving chart " + chart_key
    query = @seatsio.client.charts.retrieve(chart_key)

    assert_kind_of(RestClient::Response, query)
  end

  def test_get_chart_with_events
    chart_key = create_chart_from_file
    query = @seatsio.client.charts.retrieve_with_events(chart_key)
    assert_kind_of(RestClient::Response, query)
  end

end
