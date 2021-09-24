require 'test_helper'
require 'util'

class RetrieveObjectInfosTest < SeatsioTestClient
  def test_retrieve_object_info
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    object_infos = @seatsio.events.retrieve_object_infos key: event.key, labels: ['A-1', 'A-2']
    assert_equal(Seatsio::ObjectInfo::FREE, object_infos['A-1'].status)
    assert_equal(Seatsio::ObjectInfo::FREE, object_infos['A-2'].status)
    assert_nil(object_infos['A-3'])
  end
end
