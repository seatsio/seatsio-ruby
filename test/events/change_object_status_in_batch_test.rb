require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/events/change_object_status_in_batch_request'

class ChangeObjectStatusInBatchTest < SeatsioTestClient
  def test_change_object_status_in_batch
    chart_key1 = create_test_chart
    event1 = @seatsio.events.create chart_key: chart_key1
    chart_key2 = create_test_chart
    event2 = @seatsio.events.create chart_key: chart_key2

    res = @seatsio.events.change_object_status_in_batch([{ :event => event1.key, :objects => ['A-1'], :status => 'foo'}, { :event => event2.key, :objects => ['A-2'], :status => 'fa'}])

    assert_equal('foo', res[0].objects['A-1'].status)
    assert_equal('foo', @seatsio.events.retrieve_object_status(key: event1.key, object_key: 'A-1').status)

    assert_equal('fa', res[1].objects['A-2'].status)
    assert_equal('fa', @seatsio.events.retrieve_object_status(key: event2.key, object_key: 'A-2').status)
  end
end
