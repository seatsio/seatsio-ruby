require 'test_helper'
require 'util'

class RetrieveEventTest < SeatsioTestClient
  def test_retrieve_event
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_operator(retrieved_event.id, :!=, 0)
    assert_false(retrieved_event.is_event_in_season)
    assert_operator(retrieved_event.key, :!=, nil)
    assert_equal(chart_key, retrieved_event.chart_key)
    assert_equal('INHERIT', retrieved_event.table_booking_config.mode)
    assert_equal(true, retrieved_event.supports_best_available)
    assert_nil(retrieved_event.for_sale_config)
    assert_nil(retrieved_event.updated_on)
    # TODO: assert_that(retrieved_event.created_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end

  def test_retrieve_season
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key

    retrieved_season = @seatsio.events.retrieve key: season.key

    assert_not_equal(0, retrieved_season.id)
    assert_not_nil(retrieved_season.key)
    assert_true(retrieved_season.is_top_level_season)
    assert_equal([], retrieved_season.partial_season_keys)
    assert_equal([], retrieved_season.events)
    assert_equal(chart_key, season.chart_key)
    assert_equal(season.table_booking_config.mode, 'INHERIT')
    assert_nil(season.for_sale_config)
    assert_nil(season.updated_on)
  end
end
