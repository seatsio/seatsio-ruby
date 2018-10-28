require "test_helper"
require "util"

class CopyDraftVersionTest < SeatsioTestClient
  def test_copy_draft_version
    chart = @seatsio.charts.create("oldname")
    @seatsio.events.create key: chart.key
    @seatsio.charts.update(chart.key, "newname")

    copied_chart = @seatsio.charts.copy_draft_version(chart.key)

    assert_equal("newname (copy)", copied_chart.name)
  end
end
