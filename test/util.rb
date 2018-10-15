require "net/http"
require "json"

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