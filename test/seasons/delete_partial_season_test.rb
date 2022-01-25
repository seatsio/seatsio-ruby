require 'test_helper'
require 'util'
require 'seatsio/domain'

class DeletePartialSeasonTest < SeatsioTestClient
  def test_delete_partial_season
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key
    partial_season = @seatsio.seasons.create_partial_season top_level_season_key: season.key

    @seatsio.seasons.delete_partial_season top_level_season_key: season.key, partial_season_key: partial_season.key

    assert_raises(Seatsio::Exception::SeatsioException) do
      @seatsio.seasons.retrieve_partial_season top_level_season_key: season.key, partial_season_key: partial_season.key
    end
  end
end
