require 'test_helper'
require 'util'

class RetrieveObjectInfoTest < SeatsioTestClient
  def test_retrieve_object_info
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    object_info = @seatsio.events.retrieve_object_info key: event.key, object_key: 'A-1'
    assert_equal(Seatsio::ObjectInfo::FREE, object_info.status)
    assert_true(object_info.for_sale)
  end
end
