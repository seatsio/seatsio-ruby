require 'test_helper'
require 'util'

class UpdateEventTest < SeatsioTestClient
  def test_update_chart_key
    chart1 = @seatsio.charts.create
    event = @seatsio.events.create key: chart1.key
    chart2 = @seatsio.charts.create
  
    @seatsio.events.update key: event.key, chart_key: chart2.key
  
    retrieved_event = @seatsio.events.retrieve(event.key)
    assert_equal(event.key, retrieved_event.key)
    assert_equal(chart2.key, retrieved_event.chart_key)

    # TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end
  
  def test_update_event_key
    chart = @seatsio.charts.create
    event = @seatsio.events.create key: chart.key
  
    @seatsio.events.update key: event.key, event_key: 'newKey'
  
    retrieved_event = @seatsio.events.retrieve('newKey')
    assert_equal('newKey', retrieved_event.key)
    assert_equal(event.id, retrieved_event.id)
    # TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end 
  
  def test_update_book_whole_tables
    chart = @seatsio.charts.create
    event = @seatsio.events.create key: chart.key
  
    @seatsio.events.update key: event.key, book_whole_tables: true
  
    retrieved_event = @seatsio.events.retrieve(event.key)
    assert_equal(true, retrieved_event.book_whole_tables)
    # TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  
    @seatsio.events.update key: event.key, book_whole_tables: false
  
    retrieved_event = @seatsio.events.retrieve(event.key)
    assert_equal(false, retrieved_event.book_whole_tables)
    # TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end
  
  def test_update_table_booking_modes
    chart_key = create_test_chart_with_tables
    event = @seatsio.events.create key: chart_key, table_booking_modes: {'T1': 'BY_TABLE'}
  
    @seatsio.events.update key: event.key, table_booking_modes: {'T1': 'BY_SEAT'}
  
    retrieved_event = @seatsio.events.retrieve(event.key)
    assert_equal({'T1' => 'BY_SEAT'}, retrieved_event.table_booking_modes)
    #TODO: assert_that(retrieved_event.updated_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end
end
