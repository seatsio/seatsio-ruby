require 'test_helper'
require 'util'

class UpdateSeasonTest < SeatsioTestClient
  def test_update_season_key
    chart = @seatsio.charts.create
    season = @seatsio.seasons.create chart_key: chart.key

    @seatsio.seasons.update key: season.key, event_key: 'newKey'

    retrieved_season = @seatsio.seasons.retrieve key: 'newKey'
    assert_equal('newKey', retrieved_season.key)
    assert_equal(season.id, retrieved_season.id)
  end

  def test_update_table_booking_config
    chart_key = create_test_chart_with_tables
    season = @seatsio.seasons.create chart_key: chart_key, table_booking_config: Seatsio::TableBookingConfig::custom({'T1' => 'BY_TABLE'})

    @seatsio.seasons.update key: season.key, table_booking_config: Seatsio::TableBookingConfig::custom({'T1' => 'BY_SEAT'})

    retrieved_season = @seatsio.seasons.retrieve key: season.key
    assert_equal({'T1' => 'BY_SEAT'}, retrieved_season.table_booking_config.tables)
  end

  def test_update_object_categories
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key, object_categories: {'A-1' => 10}

    @seatsio.seasons.update key: season.key, object_categories: {'A-2' => 9}

    retrieved_season = @seatsio.seasons.retrieve key: season.key
    assert_equal({'A-2' => 9}, retrieved_season.object_categories)
  end

  def test_update_categories
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key

    @seatsio.seasons.update key: season.key, categories: [Seatsio::Category.new('eventCat1', 'event level category', '#AAABBB')]

    retrieved_season = @seatsio.seasons.retrieve key: season.key
    assert_equal(TEST_CHART_CATEGORIES.size + 1, retrieved_season.categories.size)
    assert_equal(TEST_CHART_CATEGORIES[0], retrieved_season.categories[0])
    assert_equal(TEST_CHART_CATEGORIES[1], retrieved_season.categories[1])
    assert_equal(TEST_CHART_CATEGORIES[2], retrieved_season.categories[2])
    assert_equal(Seatsio::Category.new('eventCat1', 'event level category', '#AAABBB'), retrieved_season.categories[3])
  end

  def test_update_name
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key, name: 'A season'

    @seatsio.seasons.update key: season.key, name: 'Another season'

    retrieved_season = @seatsio.seasons.retrieve key: season.key
    assert_equal('Another season', retrieved_season.name)
  end

  def test_update_for_sale_propagated
    chart_key = create_test_chart
    season = @seatsio.seasons.create chart_key: chart_key

    @seatsio.seasons.update key: season.key, for_sale_propagated: false

    retrieved_season = @seatsio.seasons.retrieve key: season.key
    assert_false(retrieved_season.for_sale_propagated)
  end
end
