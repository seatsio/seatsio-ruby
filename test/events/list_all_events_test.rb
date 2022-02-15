require 'test_helper'
require 'util'

class ListAllEventsTest < SeatsioTestClient
  def test_list_all_events
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    event2 = @seatsio.events.create chart_key: chart.key
    event3 = @seatsio.events.create chart_key: chart.key

    events = @seatsio.events.list

    events_keys = events.collect {|event| event.key}
    assert_equal([event3.key, event2.key, event1.key], events_keys)
  end

  def test_list_all_seasons
    chart = @seatsio.charts.create
    season1 = @seatsio.seasons.create chart_key: chart.key
    season2 = @seatsio.seasons.create chart_key: chart.key
    season3 = @seatsio.seasons.create chart_key: chart.key

    seasons = @seatsio.events.list

    are_seasons = seasons.collect {|season| season.is_season}
    assert_equal([true, true, true], are_seasons)
  end
end
