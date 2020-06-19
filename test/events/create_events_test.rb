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

  def test_book_whole_tables_can_be_passed_in
    chart_key = create_test_chart
    event_creation_params = [
        {:book_whole_tables => true},
        {:book_whole_tables => false}
    ]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)
    assert_equal(2, events.length)
    assert_true(events[0].book_whole_tables)
    assert_false(events[1].book_whole_tables)
  end

  def test_table_booking_modes_can_be_passed_in
    chart_key = create_test_chart_with_tables
    event_creation_params = [
        {:table_booking_modes => {'T1' => 'BY_TABLE', 'T2' => 'BY_SEAT'}},
        {:table_booking_modes => {'T1' => 'BY_SEAT', 'T2' => 'BY_TABLE'}}
    ]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)
    assert_equal(2, events.length)
    assert_equal({'T1' => 'BY_TABLE', 'T2' => 'BY_SEAT'}, events[0].table_booking_modes)
    assert_equal({'T1' => 'BY_SEAT', 'T2' => 'BY_TABLE'}, events[1].table_booking_modes)
    assert_false(events[0].book_whole_tables)
    assert_false(events[1].book_whole_tables)
  end

  def social_distancing_ruleset_key_can_be_passed_in
    chart_key = create_test_chart
    @seatsio.charts.save_social_distancing_rulesets(chart_key, {
        "ruleset1" => {"name" => "My first ruleset"}
    })
    event_creation_params = [
        {:social_distancing_ruleset_key => "ruleset1"},
        {:social_distancing_ruleset_key => "ruleset1"}
    ]

    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(2, events.length)
    assert_equal("ruleset1", events[0].social_distancing_ruleset_key)
    assert_equal("ruleset2", events[1].social_distancing_ruleset_key)
  end

end
