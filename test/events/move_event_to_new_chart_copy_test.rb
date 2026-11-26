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

  def test_events_are_moved_to_one_new_chart_copy
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    event2 = @seatsio.events.create chart_key: chart.key

    moved_events = @seatsio.events.move_events_to_new_chart_copy([event2.key, event1.key])

    assert_equal([event2.key, event1.key], moved_events.map(&:key))
    assert_not_equal(chart.key, moved_events[0].chart_key)
    assert_equal(moved_events[0].chart_key, moved_events[1].chart_key)
  end
end
