require 'test_helper'
require 'util'
require 'seatsio/domain'

class CreateSeasonTest < SeatsioTestClient
  def test_chart_key_is_required
    chart_key = create_test_chart

    season = @seatsio.seasons.create chart_key: chart_key

    assert_not_equal(0, season.id)
    assert_not_nil(season.key)
    assert_equal([], season.partial_season_keys)
    assert_equal([], season.events)

    season_event = season.season_event
    assert_not_equal(0, season_event.id)
    assert_not_nil(season_event.key)
    assert_equal(chart_key, season_event.chart_key)
    assert_equal(season_event.table_booking_config.mode, 'INHERIT')
    assert_nil(season_event.for_sale_config)
    assert_nil(season_event.updated_on)
  end

  def test_key_is_optional
    chart = @seatsio.charts.create

    season = @seatsio.seasons.create chart_key: chart.key, key: 'aSeason'

    assert_equal('aSeason', season.key)
  end

  def test_number_of_events_is_optional
    chart = @seatsio.charts.create

    season = @seatsio.seasons.create chart_key: chart.key, number_of_events: 2

    assert_equal(2, season.events.length)
  end

  def test_event_keys_is_optional
    chart = @seatsio.charts.create

    season = @seatsio.seasons.create chart_key: chart.key, event_keys: ['event1', 'event2']

    assert_equal(['event1', 'event2'], season.events.map { |e| e.key })
  end

  def test_table_booking_config_can_be_passed_in
    chart_key = create_test_chart_with_tables
    table_booking_config = Seatsio::TableBookingConfig::custom({ 'T1' => 'BY_TABLE', 'T2' => 'BY_SEAT' })

    season = @seatsio.seasons.create chart_key: chart_key, table_booking_config: table_booking_config

    assert_equal(table_booking_config.mode, season.season_event.table_booking_config.mode)
    assert_equal(table_booking_config.tables, season.season_event.table_booking_config.tables)
  end

  def test_social_distancing_ruleset_key_is_optional
    chart_key = create_test_chart
    @seatsio.charts.save_social_distancing_rulesets(chart_key, {
      "ruleset1" => { "name" => "My first ruleset" }
    })

    season = @seatsio.seasons.create chart_key: chart_key, social_distancing_ruleset_key: "ruleset1"

    assert_equal("ruleset1", season.season_event.social_distancing_ruleset_key)
  end
end
