require 'test_helper'
require 'util'

class ListEventsOfChartTest < SeatsioTestClient
  def test_list_all_events_of_chart
    chart = @seatsio.charts.create
    other_chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    @seatsio.events.create chart_key: other_chart.key
    event2 = @seatsio.events.create chart_key: chart.key
    event3 = @seatsio.events.create chart_key: chart.key

    events = @seatsio.charts.events(chart.key)

    assert_equal([event3.key, event2.key, event1.key], events.collect {|event| event.key})
  end

  def test_list_pages_of_events_of_chart
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    event2 = @seatsio.events.create chart_key: chart.key
    event3 = @seatsio.events.create chart_key: chart.key

    first_page = @seatsio.charts.events(chart.key).first_page(2)

    assert_equal([event3.id, event2.id], first_page.collect {|event| event.id})
    assert_equal(event2.id, first_page.next_page_starts_after)
    assert_nil(first_page.previous_page_ends_before)

    page_after = @seatsio.charts.events(chart.key).page_after(first_page.next_page_starts_after, 2)

    assert_equal([event1.id], page_after.collect {|event| event.id})
    assert_nil(page_after.next_page_starts_after)
    assert_equal(event1.id, page_after.previous_page_ends_before)
  end
end
