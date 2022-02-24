require 'test_helper'
require 'util'

class ListStatusChangesTest < SeatsioTestClient
  def test_status_changes
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.change_object_status(event.key, ['A-1'], status= 'status1')
    @seatsio.events.change_object_status(event.key, ['A-1'], status= 'status2')
    @seatsio.events.change_object_status(event.key, ['A-1'], status= 'status3')

    status_changes = @seatsio.events.list_status_changes(event.key)
    assert_equal(%w(status3 status2 status1), status_changes.collect {|changes| changes.status})
  end

  def test_properties_of_status_change
    now = Time.now
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    object_properties = {:objectId => 'A-1', :extraData => {'foo': 'bar'}}
    @seatsio.events.hold(event.key, object_properties, hold_token.hold_token, order_id: 'order1')

    status_changes =  @seatsio.events.list_status_changes(event.key).to_a
    status_change = status_changes[0]

    assert_operator(status_change.id, :!=, 0)

    #TODO: assert_that(status_change.date).is_between_now_minus_and_plus_minutes(now, 1)
    assert_equal('reservedByToken', status_change.status)
    assert_equal('A-1', status_change.object_label)
    assert_equal(event.id, status_change.event_id)
    assert_equal({'foo' => 'bar'}, status_change.extra_data)
    assert_equal('API_CALL', status_change.origin.type)
    assert_equal('order1', status_change.order_id)
    assert_equal(hold_token.hold_token, status_change.hold_token)
    assert_not_nil(status_change.origin.ip)
    assert_true(status_change.is_present_on_chart)
    assert_nil(status_change.not_present_on_chart_reason)
  end

  def test_not_present_on_chart_anymore
    chart_key = create_test_chart_with_tables
    event = @seatsio.events.create chart_key: chart_key, table_booking_config: Seatsio::TableBookingConfig::all_by_table()
    @seatsio.events.book(event.key, ['T1'])
    @seatsio.events.update key: event.key, table_booking_config: Seatsio::TableBookingConfig::all_by_seat()

    status_changes =  @seatsio.events.list_status_changes(event.key).to_a
    status_change = status_changes[0]

    assert_false(status_change.is_present_on_chart)
    assert_equal('SWITCHED_TO_BOOK_BY_SEAT', status_change.not_present_on_chart_reason)
  end

end
