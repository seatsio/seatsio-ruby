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
    object_properties = {:objectId => 'A-1', :extraData => {'foo': 'bar'}}
    @seatsio.events.change_object_status(event.key, object_properties, 'status1', nil, 'order1')

    status_changes =  @seatsio.events.list_status_changes(event.key).to_a
    status_change = status_changes[0]

    assert_operator(status_change.id, :!=, 0)

    #TODO: assert_that(status_change.date).is_between_now_minus_and_plus_minutes(now, 1)
    assert_equal('status1', status_change.status)
    assert_equal('A-1', status_change.object_label)
    assert_equal(event.id, status_change.event_id)
    assert_equal({'foo' => 'bar'}, status_change.extra_data)
  end

end
