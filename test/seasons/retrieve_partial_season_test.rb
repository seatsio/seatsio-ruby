require 'test_helper'
require 'util'
require 'seatsio/domain'

class RetrieveSeasonTest < SeatsioTestClient
  def test_retrieve_partial_season
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key
    partial_season = @seatsio.seasons.create_partial_season top_level_season_key: season.key

    retrieved_partial_season = @seatsio.seasons.retrieve_partial_season top_level_season_key: season.key, partial_season_key: partial_season.key

    assert_not_equal(0, retrieved_partial_season.id)
    assert_not_nil(retrieved_partial_season.key)
    assert_equal([], retrieved_partial_season.events)

    season_event = retrieved_partial_season.season_event
    assert_operator(season_event.id, :!=, 0)
    assert_operator(season_event.key, :!=, nil)
    assert_equal(chart_key, season_event.chart_key)
    assert_equal(season_event.table_booking_config.mode, 'INHERIT')
    assert_nil(season_event.for_sale_config)
    assert_nil(season_event.updated_on)
  end
end
