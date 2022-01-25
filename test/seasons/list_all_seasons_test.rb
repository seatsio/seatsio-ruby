require 'test_helper'
require 'util'

class ListAllSeasonsTest < SeatsioTestClient
  def test_list_all_seasons
    chart = @seatsio.charts.create
    season1 = @seatsio.seasons.create chart_key: chart.key
    season2 = @seatsio.seasons.create chart_key: chart.key
    season3 = @seatsio.seasons.create chart_key: chart.key

    seasons = @seatsio.seasons.list

    season_keys = seasons.collect {|season| season.key}
    assert_equal([season3.key, season2.key, season1.key], season_keys)
  end

end
