require 'test_helper'
require 'util'

class RetrieveEventObjectInfoTest < SeatsioTestClient
  def test_retrieve_object_info
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(Seatsio::EventObjectInfo::FREE, object_info.status)
    assert_true(object_info.for_sale)
  end
end
