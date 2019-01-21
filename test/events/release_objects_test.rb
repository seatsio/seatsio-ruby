require 'test_helper'
require 'util'

class ReleaseObjectsTest < SeatsioTestClient
  def test_release_objects
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    @seatsio.events.book(event.key, %w(A-1 A-2))
  
    res = @seatsio.events.release(event.key, %w(A-1 A-2))
  
    a1_status = @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-1').status
    a2_status = @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-2').status
    a3_status = @seatsio.events.retrieve_object_status(key: event.key, object_key: 'A-3').status

    assert_equal(Seatsio::Domain::ObjectStatus::FREE, a1_status)
    assert_equal(Seatsio::Domain::ObjectStatus::FREE, a2_status)
    assert_equal(Seatsio::Domain::ObjectStatus::FREE, a3_status)

    assert_equal(res.objects.keys, ['A-1', 'A-2'])
  end
  
  def test_with_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.hold(event.key, ['A-1'], hold_token.hold_token)
  
    @seatsio.events.release(event.key, ['A-1'], hold_token.hold_token)
  
    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(Seatsio::Domain::ObjectStatus::FREE, status.status)
    assert_nil(status.hold_token)
  end
  
  def test_with_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create key: chart_key
    @seatsio.events.book(event.key, ['A-1'])
  
    @seatsio.events.release(event.key, ['A-1'], nil, 'order1')
  
    status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal('order1', status.order_id)
  end
end
