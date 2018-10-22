require "test_helper"
require "util"

class RemoveTagTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user["secretKey"], "https://api-staging.seatsio.net")
  end

  def test_remove_tag
    chart = @seatsio.client.charts.create
    @seatsio.client.charts.add_tag(chart.key, "tag1")
    @seatsio.client.charts.add_tag(chart.key, "tag2")

    @seatsio.client.charts.remove_tag(chart.key, "tag2")

    retrieved_chart = @seatsio.client.charts.retrieve(chart.key)

    assert_equal(['tag1'], retrieved_chart.tags)
  end
end