require "test_helper"
require "util"

class AddTagTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user["secretKey"], "https://api-staging.seatsio.net")
  end

  def test_add_tag
    chart = @seatsio.charts.create
    @seatsio.charts.add_tag(chart.key, "tag1")
    @seatsio.charts.add_tag(chart.key, "tag2")

    retreived_chart = @seatsio.charts.retrieve(chart.key)

    assert_includes(retreived_chart.tags, "tag1")
    assert_includes(retreived_chart.tags, "tag2")
  end

  def test_special_characters
    chart = @seatsio.charts.create
    @seatsio.charts.add_tag(chart.key, "'tag1/:-'<>")

    retreived_chart = @seatsio.charts.retrieve(chart.key)

    assert_includes(retreived_chart.tags, "'tag1/:-'<>")
  end
end
