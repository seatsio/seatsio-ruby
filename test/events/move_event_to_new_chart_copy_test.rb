require 'test_helper'
require 'util'

class MoveEventToNewChartCopyTest < SeatsioTestClient
  def test_event_is_moved_to_new_chart_copy
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    moved_event = @seatsio.events.move_to_new_chart_copy(event.key)

    assert_equal(event.key, moved_event.key)
    assert_not_equal(event.chart_key, moved_event.chart_key)
  end
end
