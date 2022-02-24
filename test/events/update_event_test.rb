require 'test_helper'
require 'util'

class UpdateEventTest < SeatsioTestClient
  def test_update_chart_key
    chart1 = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart1.key
    chart2 = @seatsio.charts.create

    @seatsio.events.update key: event.key, chart_key: chart2.key

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(event.key, retrieved_event.key)
    assert_equal(chart2.key, retrieved_event.chart_key)

    # TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end

  def test_update_event_key
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.update key: event.key, event_key: 'newKey'

    retrieved_event = @seatsio.events.retrieve key: 'newKey'
    assert_equal('newKey', retrieved_event.key)
    assert_equal(event.id, retrieved_event.id)
    # TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end

  def test_update_table_booking_config
    chart_key = create_test_chart_with_tables
    event = @seatsio.events.create chart_key: chart_key, table_booking_config: Seatsio::TableBookingConfig::custom({'T1' => 'BY_TABLE'})

    @seatsio.events.update key: event.key, table_booking_config: Seatsio::TableBookingConfig::custom({'T1' => 'BY_SEAT'})

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal({'T1' => 'BY_SEAT'}, retrieved_event.table_booking_config.tables)
    #TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end

  def test_update_social_distancing_ruleset_key
    chart_key = create_test_chart
    @seatsio.charts.save_social_distancing_rulesets(chart_key, {
      "ruleset1" => {"name" => "My first ruleset"},
      "ruleset2" => {"name" => "My second ruleset"}
    })
    event = @seatsio.events.create chart_key: chart_key, social_distancing_ruleset_key: 'ruleset1'

    @seatsio.events.update key: event.key, social_distancing_ruleset_key: 'ruleset2'

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal('ruleset2', retrieved_event.social_distancing_ruleset_key)
  end

  def test_remove_social_distancing_ruleset_key
    chart_key = create_test_chart
    @seatsio.charts.save_social_distancing_rulesets(chart_key, {
      "ruleset1" => {"name" => "My first ruleset"}
    })
    event = @seatsio.events.create chart_key: chart_key, social_distancing_ruleset_key: 'ruleset1'

    @seatsio.events.update key: event.key, social_distancing_ruleset_key: ''

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_nil(retrieved_event.social_distancing_ruleset_key)
  end

  def test_update_object_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, object_categories: {'A-1' => 10}

    @seatsio.events.update key: event.key, object_categories: {'A-2' => 9}

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal({'A-2' => 9}, retrieved_event.object_categories)
  end

  def test_remove_object_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, object_categories: {'A-1' => 10}

    @seatsio.events.update key: event.key, object_categories: { }

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_nil(retrieved_event.object_categories)
  end
end
