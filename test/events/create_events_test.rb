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
    assert_equal('INHERIT', event.table_booking_config.mode)
    assert_equal(true, event.supports_best_available)
    assert_nil(event.for_sale_config)
    assert_not_nil(event.created_on)
    assert_nil(event.updated_on)
  end

  def test_event_key_can_be_passed_in
    chart_key = create_test_chart
    event_creation_params = [
        {event_key: 'event1'},
        {event_key: 'event2'}
    ]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(2, events.length)
    assert_equal("event1", events[0].key)
    assert_equal("event2", events[1].key)
  end

  def test_table_booking_config_can_be_passed_in
    chart_key = create_test_chart_with_tables
    event_creation_params = [
        {table_booking_config: Seatsio::TableBookingConfig::custom({'T1': 'BY_TABLE', 'T2': 'BY_SEAT'})},
        {table_booking_config: Seatsio::TableBookingConfig::custom({'T1': 'BY_SEAT', 'T2': 'BY_TABLE'})}
    ]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)
    assert_equal(2, events.length)
    assert_equal('CUSTOM', events[0].table_booking_config.mode)
    assert_equal({'T1' => 'BY_TABLE', 'T2' => 'BY_SEAT'}, events[0].table_booking_config.tables)
    assert_equal('CUSTOM', events[1].table_booking_config.mode)
    assert_equal({'T1' => 'BY_SEAT', 'T2' => 'BY_TABLE'}, events[1].table_booking_config.tables)
  end

  def test_social_distancing_ruleset_key_can_be_passed_in
    chart_key = create_test_chart
    @seatsio.charts.save_social_distancing_rulesets(chart_key, {
        "ruleset1" => {"name" => "My first ruleset"},
        "ruleset2" => {"name" => "My second ruleset"}
    })
    event_creation_params = [
        {:social_distancing_ruleset_key => "ruleset1"},
        {:social_distancing_ruleset_key => "ruleset2"}
    ]

    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(2, events.length)
    assert_equal("ruleset1", events[0].social_distancing_ruleset_key)
    assert_equal("ruleset2", events[1].social_distancing_ruleset_key)
  end

  def test_object_categories_can_be_passed_in
    chart_key = create_test_chart
    event_creation_params = [
      {:object_categories => {'A-1' => 10}}
    ]

    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(1, events.length)
    assert_equal({'A-1' => 10}, events[0].object_categories)
  end

  def test_categories_can_be_passed_in
    chart_key = create_test_chart
    event_creation_params = [
      {:categories => [Seatsio::Category.new('eventCat1', 'event level category', '#AAABBB')]}
    ]

    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(1, events.length)
    event = events[0]
    assert_equal(TEST_CHART_CATEGORIES.size + 1, event.categories.size)
    assert_equal(TEST_CHART_CATEGORIES[0], event.categories[0])
    assert_equal(TEST_CHART_CATEGORIES[1], event.categories[1])
    assert_equal(TEST_CHART_CATEGORIES[2], event.categories[2])
    assert_equal(Seatsio::Category.new('eventCat1', 'event level category', '#AAABBB'), event.categories[3])
  end

end
