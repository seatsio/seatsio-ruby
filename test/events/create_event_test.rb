require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/domain'

class CreateEventTest < SeatsioTestClient
  def test_chart_key_is_required
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    assert_operator(event.id, :!=, 0)
    assert_operator(event.key, :!=, nil)
    assert_equal(chart_key, event.chart_key)
    assert_equal(event.table_booking_config.mode, 'INHERIT')
    assert_nil(event.for_sale_config)
    assert_nil(event.updated_on)

    # TODO: assert_that(event.created_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end

  def test_event_key_is_optional
    chart = @seatsio.charts.create

    event = @seatsio.events.create chart_key: chart.key, event_key: 'eventje'
    assert_equal('eventje', event.key)
  end

  def test_table_booking_config_custom_can_be_used
    chart_key = create_test_chart_with_tables
    table_booking_config = Seatsio::TableBookingConfig::custom({'T1' => 'BY_TABLE', 'T2' => 'BY_SEAT'})

    event = @seatsio.events.create chart_key: chart_key, table_booking_config: table_booking_config
    assert_operator(event.key, :!=, '')
    assert_equal(table_booking_config.mode, event.table_booking_config.mode)
    assert_equal(table_booking_config.tables, event.table_booking_config.tables)
  end

  def test_table_booking_config_inherit_can_be_used
    chart_key = create_test_chart_with_tables

    event = @seatsio.events.create chart_key: chart_key, table_booking_config: Seatsio::TableBookingConfig::inherit()
    assert_operator(event.key, :!=, '')
    assert_equal('INHERIT', event.table_booking_config.mode)
  end

  def test_social_distancing_ruleset_key_is_optional
    chart_key = create_test_chart
    @seatsio.charts.save_social_distancing_rulesets(chart_key, {
        "ruleset1" => {"name" => "My first ruleset"}
    })

    event = @seatsio.events.create chart_key: chart_key, social_distancing_ruleset_key: "ruleset1"

    assert_equal("ruleset1", event.social_distancing_ruleset_key)
  end

  def test_object_categories
    chart_key = create_test_chart

    event = @seatsio.events.create chart_key: chart_key, object_categories: {'A-1' => 10}

    assert_equal({'A-1' => 10}, event.object_categories)
  end
end
