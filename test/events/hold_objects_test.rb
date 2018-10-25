require 'test_helper'
require 'util'

class HoldObjectsTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_with_hold_token
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    hold_token = @seatsio.hold_tokens.create

    res = @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token)

    status1 = @seatsio.events.retrieve_object_status(event.key, 'A-1')
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, status1.status)
    assert_equal(hold_token.hold_token, status1.hold_token)
  
    status2 = @seatsio.events.retrieve_object_status(event.key, 'A-2')
    assert_equal(Seatsio::Domain::ObjectStatus::HELD, status2.status)
    assert_equal(hold_token.hold_token, status2.hold_token)

    assert_equal({
                   'A-1' => {'own' => {'label' => '1', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}},
                   'A-2' => {'own' => {'label' => '2', 'type' => 'seat'}, 'parent' => {'label' => 'A', 'type' => 'row'}}
                 }, res.labels)
  end

  def test_with_order_id
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    hold_token = @seatsio.hold_tokens.create
  
    @seatsio.events.hold(event.key, %w(A-1 A-2), hold_token.hold_token, 'order1')
  
    status1 = @seatsio.events.retrieve_object_status(event.key, 'A-1')
    assert_equal('order1', status1.order_id)

    status2 = @seatsio.events.retrieve_object_status(event.key, 'A-2')
    assert_equal('order1', status2.order_id)
  end
end
