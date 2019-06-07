require 'test_helper'
require 'util'

class ListEventsAfterTest < SeatsioTestClient
  def test_with_previous_page
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    event2 = @seatsio.events.create chart_key: chart.key
    event3 = @seatsio.events.create chart_key: chart.key

    events = @seatsio.events.list.page_after(event3.id)
    assert_equal([event2.id, event1.id], events.collect {|event| event.id})
    assert_nil(events.next_page_starts_after)
    assert_equal(event2.id, events.previous_page_ends_before)
  end

  def test_with_next_and_previous_pages
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    event2 = @seatsio.events.create chart_key: chart.key
    event3 = @seatsio.events.create chart_key: chart.key

    events = @seatsio.events.list.page_after(event3.id, 1)

    assert_equal([event2.id], events.collect {|event| event.id})
    assert_equal(event2.id, events.next_page_starts_after)
    assert_equal(event2.id, events.previous_page_ends_before)
  end
end
