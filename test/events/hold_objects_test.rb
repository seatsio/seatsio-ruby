require 'test_helper'
require 'util'

class HoldObjectsTest < SeatsioTestClient
  def test_with_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    res = @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token)

    status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, status1.status)
    assert_equal(hold_token.hold_token, status1.hold_token)

    status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, status2.status)
    assert_equal(hold_token.hold_token, status2.hold_token)

    assert_equal(res.objects.keys, ['A-1', 'A-2'])
  end

  def test_with_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create

    @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token, 'order1')

    status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal('order1', status1.order_id)

    status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal('order1', status2.order_id)
  end
end
