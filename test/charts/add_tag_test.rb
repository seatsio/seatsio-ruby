require "test_helper"
require "util"

class AddTagTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user["secretKey"], "https://api-staging.seatsio.net")
  end

  def test_add_tag
    chart = @seatsio.client.charts.create
    @seatsio.client.charts.add_tag(chart.key, "tag1")
    @seatsio.client.charts.add_tag(chart.key, "tag2")

    retreived_chart = @seatsio.client.charts.retrieve(chart.key)

    assert_includes(retreived_chart.tags, "tag1")
    assert_includes(retreived_chart.tags, "tag2")
  end

  def test_special_characters
    chart = @seatsio.client.charts.create
    @seatsio.client.charts.add_tag(chart.key, "'tag1/:-'<>")

    retreived_chart = @seatsio.client.charts.retrieve(chart.key)

    assert_includes(retreived_chart.tags, "'tag1/:-'<>")
  end
end