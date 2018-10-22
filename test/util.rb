require "rest-client"
require "json"
require 'seatsio/exception'

BASE_URL = "https://api-staging.seatsio.net"

def create_test_user
  begin
    post = RestClient.post(BASE_URL + "/system/public/users/actions/create-test-user",{})
    JSON.parse(post)
  rescue
    raise Seatsio::Exception::SeatsioException.new("Failed to create a test user")
  end
end

def create_chart_from_file
  chart_file = File.read(Dir.pwd + "/test/sampleChart.json")
  chart_key = SecureRandom.uuid

  url = "#{BASE_URL}/system/public/#{@user["designerKey"]}/charts/#{chart_key}"
  post = RestClient.post(url, chart_file)

  if post.is_a?(RestClient::Response)
    puts "Chart created"
    chart_key
  else
    raise "Failed to create a chart from file test/sampleChart.json"
  end
end
