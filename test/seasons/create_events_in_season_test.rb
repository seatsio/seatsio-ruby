require 'test_helper'
require 'util'
require 'seatsio/domain'

class CreateEventsInSeasonTest < SeatsioTestClient

  def test_event_keys
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key

    events = @seatsio.seasons.create_events key: season.key,
                                                    event_keys: %w[event1 event2]

    assert_equal(%w[event2 event1], events.map { |e| e.key })
    assert_true(events[0].is_event_in_season)
    assert_equal(season.key, events[0].top_level_season_key)
  end

  def test_number_of_events
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key

    events = @seatsio.seasons.create_events key: season.key,
                                                    number_of_events: 2

    assert_equal(2, events.length)
  end
end
