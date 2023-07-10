require 'test_helper'
require 'util'

class UpdateEventTest < SeatsioTestClient
  def test_update_chart_key
    chart1 = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart1.key
    chart2 = @seatsio.charts.create

    @seatsio.events.update key: event.key, chart_key: chart2.key

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(event.key, retrieved_event.key)
    assert_equal(chart2.key, retrieved_event.chart_key)
  end

  def test_update_event_key
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.update key: event.key, event_key: 'newKey'

    retrieved_event = @seatsio.events.retrieve key: 'newKey'
    assert_equal('newKey', retrieved_event.key)
    assert_equal(event.id, retrieved_event.id)
  end

  def test_update_table_booking_config
    chart_key = create_test_chart_with_tables
    event = @seatsio.events.create chart_key: chart_key, table_booking_config: Seatsio::TableBookingConfig::custom({'T1' => 'BY_TABLE'})

    @seatsio.events.update key: event.key, table_booking_config: Seatsio::TableBookingConfig::custom({'T1' => 'BY_SEAT'})

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal({'T1' => 'BY_SEAT'}, retrieved_event.table_booking_config.tables)
  end

  def test_update_object_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, object_categories: {'A-1' => 10}

    @seatsio.events.update key: event.key, object_categories: {'A-2' => 9}

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal({'A-2' => 9}, retrieved_event.object_categories)
  end

  def test_remove_object_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, object_categories: {'A-1' => 10}

    @seatsio.events.update key: event.key, object_categories: { }

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_nil(retrieved_event.object_categories)
  end

  def test_update_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.update key: event.key, categories: [Seatsio::Category.new('eventCat1', 'event level category', '#AAABBB')]

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(TEST_CHART_CATEGORIES.size + 1, retrieved_event.categories.size)
    assert_equal(TEST_CHART_CATEGORIES[0], retrieved_event.categories[0])
    assert_equal(TEST_CHART_CATEGORIES[1], retrieved_event.categories[1])
    assert_equal(TEST_CHART_CATEGORIES[2], retrieved_event.categories[2])
    assert_equal(Seatsio::Category.new('eventCat1', 'event level category', '#AAABBB'), retrieved_event.categories[3])
  end

  def test_remove_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, categories: [Seatsio::Category.new('eventCat1', 'event level category', '#AAABBB')]

    @seatsio.events.update key: event.key, categories: []

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(TEST_CHART_CATEGORIES.size, retrieved_event.categories.size)
  end

  def test_update_name
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, name: 'An event'

    @seatsio.events.update key: event.key, name: 'Another event'

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal('Another event', retrieved_event.name)
  end

  def test_update_date
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key, date: Date.iso8601('2022-01-05')

    @seatsio.events.update key: event.key, date: Date.iso8601('2023-01-05')

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(Date.iso8601('2023-01-05'), retrieved_event.date)
  end
end
