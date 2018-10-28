require "test_helper"
require "util"

class CopyChartTest < SeatsioTestClient
  def test_copy_chart
    chart = @seatsio.charts.create("my chart", "BOOTHS")
    copied_chart = @seatsio.charts.copy(chart.key)

    assert_equal("my chart (copy)", copied_chart.name)

    drawing = @seatsio.charts.retrieve_published_version(copied_chart.key)
    assert_equal("BOOTHS", drawing.venue_type)
  end
end
