require 'test_helper'
require 'util'
require 'seatsio/domain'

class DeleteSeasonTest < SeatsioTestClient
  def test_delete_season
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key

    @seatsio.seasons.delete key: season.key

    assert_raises(Seatsio::Exception::SeatsioException) do
      @seatsio.seasons.retrieve key: season.key
    end
  end
end
