require 'test_helper'
require 'util'

class ListStatusChangesForObjectTest < SeatsioTestClient
  def test_list_status_changes_for_object
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    @seatsio.events.change_object_status_in_batch(
      [
        { :event => event.key, :objects => ['A-1'], :status => 'status1' },
        { :event => event.key, :objects => ['A-1'], :status => 'status2' },
        { :event => event.key, :objects => ['A-1'], :status => 'status3' },
        { :event => event.key, :objects => ['A-1'], :status => 'status4' }
      ]
    )
    wait_for_status_changes(event, 4)


    status_changes = @seatsio.events.list_status_changes(event.key, 'A-1')
    assert_equal(%w(status4 status3 status2 status1), status_changes.collect {|status| status.status})
  end

end
