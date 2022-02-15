require 'test_helper'
require 'util'
require 'seatsio/domain'

class RetrieveSeasonTest < SeatsioTestClient
  def test_retrieve_season
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key

    retrieved_season = @seatsio.seasons.retrieve key: season.key

    assert_not_equal(0, retrieved_season.id)
    assert_not_nil(retrieved_season.key)
    assert_equal([], retrieved_season.partial_season_keys)
    assert_equal([], retrieved_season.events)
    assert_equal(chart_key, season.chart_key)
    assert_equal(season.table_booking_config.mode, 'INHERIT')
    assert_nil(season.for_sale_config)
    assert_nil(season.updated_on)
  end
end
