require 'test_helper'
require 'util'
require 'seatsio/domain'

class CreateSeasonTest < SeatsioTestClient
  def test_chart_key_is_required
    chart_key = create_test_chart

    season = @seatsio.seasons.create chart_key: chart_key

    assert_not_equal(0, season.id)
    assert_not_nil(season.key)
    assert_true(season.is_top_level_season)
    assert_nil(season.top_level_season_key)
    assert_equal([], season.partial_season_keys)
    assert_equal([], season.events)
    assert_equal(chart_key, season.chart_key)
    assert_equal(season.table_booking_config.mode, 'INHERIT')
    assert_nil(season.for_sale_config)
    assert_nil(season.updated_on)
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

    assert_equal(table_booking_config.mode, season.table_booking_config.mode)
    assert_equal(table_booking_config.tables, season.table_booking_config.tables)
  end
end
