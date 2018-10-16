require "test_helper"
require "util"

class CopyDraftVersionTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user["secretKey"], "https://api-staging.seatsio.net")
  end

  def test_copy_draft_version
    chart = @seatsio.client.charts.create("oldname")
    @seatsio.client.events.create(chart.key)
    @seatsio.client.charts.update(chart.key, "newname")

    copied_chart = @seatsio.client.charts.copy_draft_version(chart.key)

    assert_equal("newname (copy)", copied_chart.name)
  end
end