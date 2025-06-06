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

  def test_name_is_optional
    chart = @seatsio.charts.create

    season = @seatsio.seasons.create chart_key: chart.key, name: 'aSeason'

    assert_equal('aSeason', season.name)
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

  def test_channels_can_be_passed_in
    chart_key = create_test_chart
    channels = [
      Seatsio::Channel.new("channelKey1", "channel 1", "#FF0000", 1, %w[A-1 A-2]),
      Seatsio::Channel.new("channelKey2", "channel 2", "#0000FF", 2, [])
    ]

    season = @seatsio.seasons.create chart_key: chart_key, channels: channels

    assert_equal(channels, season.channels)
  end

  def test_for_sale_config_can_be_passed_in
    chart_key = create_test_chart
    for_sale_config = Seatsio::ForSaleConfig.new(false, ["A-1"], {"GA1" => 3}, ["Cat1"])

    season = @seatsio.seasons.create chart_key: chart_key, for_sale_config: for_sale_config

    assert_equal(for_sale_config, season.for_sale_config)
  end
end
