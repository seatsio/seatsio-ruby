require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChartReportsTest < SeatsioTestClient

  def test_multiple_events
    chart_key = create_test_chart
    event_creation_params = [{}, {}]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(2, events.length)
    events.each {|e| assert_not_nil(e.key)}
  end

  def test_single_event
    chart_key = create_test_chart
    event_creation_params = [{}]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(1, events.length)
    event = events[0]
    assert_not_equal(0, event.id)
    assert_not_nil(event.id)
    assert_not_nil(event.key)
    assert_equal(chart_key, event.chart_key)
    assert_false(event.book_whole_tables)
    assert_nil(event.supports_best_available)
    assert_nil(event.for_sale_config)
    assert_not_nil(event.created_on)
    assert_nil(event.updated_on)
  end

  def test_event_key_can_be_passed_in
    chart_key = create_test_chart
    event_creation_params = [
        {:event_key => 'event1'},
        {:event_key => 'event2'}
    ]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(2, events.length)
    assert_equal("event1", events[0].key)
    assert_equal("event2", events[1].key)
  end

end