require "rest-client"
require "json"
require 'seatsio/exception'

BASE_URL = "https://api-staging-eu.seatsio.net"

TEST_CHART_CATEGORIES = [
  Seatsio::Category.new(9, 'Cat1', '#87A9CD', false),
  Seatsio::Category.new(10, 'Cat2', '#5E42ED', false),
  Seatsio::Category.new('string11', 'Cat3', '#5E42BB', false)
]

def test_client(secretKey, workspaceKey)
  Seatsio::Client.new(Seatsio::Region.new(BASE_URL), secretKey, workspaceKey)
end

def create_test_user
  begin
    post = RestClient.post(BASE_URL + "/system/public/users/actions/create-test-company", {})
    JSON.parse(post)
  rescue Exception => e
    raise Seatsio::Exception::SeatsioException.new("Failed to create a test company because " + e.message)
  end
end

def create_test_chart_from_file(file)
  chart_file = File.read(Dir.pwd + "/test/#{file}")
  chart_key = SecureRandom.uuid

  url = "#{BASE_URL}/system/public/charts/#{chart_key}"
  post = RestClient::Request.execute method: :post, url: url, user: @user["secretKey"], payload: chart_file
  if post.is_a?(RestClient::Response)
    chart_key
  else
    raise "Failed to create a chart from file test/sampleChart.json"
  end
end

def create_test_chart
  create_test_chart_from_file('sampleChart.json')
end

def create_test_chart_with_sections
  create_test_chart_from_file('sampleChartWithSections.json')
end

def create_test_chart_with_tables
  create_test_chart_from_file('sampleChartWithTables.json')
end

def create_test_chart_with_errors
  create_test_chart_from_file('sampleChartWithErrors.json')
end
