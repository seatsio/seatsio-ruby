require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChartReportsTest < SeatsioTestClient
  def test_chart_key_is_required
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    assert_operator(event.id, :!=, 0)
    assert_operator(event.key, :!=, nil)
    assert_equal(chart_key, event.chart_key)
    assert_equal(false, event.book_whole_tables)
    assert_equal(true, event.supports_best_available)
    assert_nil(event.for_sale_config)
    assert_nil(event.updated_on)

    # TODO: assert_that(event.created_on).is_between_now_minus_and_plus_minutes(datetime.utcnow(), 1)
  end

  def test_event_key_is_optional
    chart = @seatsio.charts.create

    event = @seatsio.events.create chart_key: chart.key, event_key: 'eventje'
    assert_equal('eventje', event.key)
    assert_equal(false, event.book_whole_tables)
  end

  def test_book_whole_tables_is_optional
    chart = @seatsio.charts.create

    event = @seatsio.events.create chart_key: chart.key, book_whole_tables: true
    assert_operator(event.key, :!=, '')
    assert_equal(true, event.book_whole_tables)
  end

  def test_table_booking_modes_is_optional
    chart_key = create_test_chart_with_tables
    table_booking_modes = {'T1' => 'BY_TABLE', 'T2' => 'BY_SEAT'}

    event = @seatsio.events.create chart_key: chart_key, table_booking_modes: table_booking_modes
    assert_operator(event.key, :!=, '')
    assert_equal(false, event.book_whole_tables)
    assert_equal(table_booking_modes, event.table_booking_modes)
  end
end
