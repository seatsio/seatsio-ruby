require 'test_helper'
require 'util'
require 'seatsio/domain'

class CreatePartialSeasonTest < SeatsioTestClient

  def test_key_is_optional
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key

    partial_season = @seatsio.seasons.create_partial_season top_level_season_key: season.key, partial_season_key: 'aPartialSeason'

    assert_equal('aPartialSeason', partial_season.key)
    assert_true(partial_season.is_partial_season)
    assert_equal(season.key, partial_season.top_level_season_key)
  end

  def test_event_keys_is_optional
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key, event_keys: ['event1', 'event2']

    partial_season = @seatsio.seasons.create_partial_season top_level_season_key: season.key, event_keys: ['event1', 'event2']

    assert_equal(%w[event1 event2], partial_season.events.map { |e| e.key })
  end
end
