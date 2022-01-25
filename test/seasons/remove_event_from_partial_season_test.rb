require 'test_helper'
require 'util'
require 'seatsio/domain'

class AddEventsToPartialSeasonTest < SeatsioTestClient

  def test_remove_event_from_partial_season
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key, event_keys: %w[event1 event2]
    partial_season = @seatsio.seasons.create_partial_season top_level_season_key: season.key,
                                                            event_keys: %w[event1 event2]

    updated_season = @seatsio.seasons.remove_event_from_partial_season top_level_season_key: season.key,
                                                                       partial_season_key: partial_season.key,
                                                                       event_key: 'event2'

    assert_equal(%w[event1], updated_season.events.map { |e| e.key })
  end
end
