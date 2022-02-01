require 'test_helper'
require 'util'
require 'seatsio/domain'

class CreateEventsInSeasonTest < SeatsioTestClient

  def test_event_keys
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key

    updated_season = @seatsio.seasons.create_events key: season.key,
                                                    event_keys: %w[event1 event2]

    assert_equal(%w[event1 event2], updated_season.events.map { |e| e.key })
  end

  def test_number_of_events
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key

    updated_season = @seatsio.seasons.create_events key: season.key,
                                                    number_of_events: 2

    assert_equal(2, updated_season.events.length)
  end
end
