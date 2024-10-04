require 'test_helper'
require 'util'
require 'seatsio/domain'

class PutObjectsUpForResaleTest < SeatsioTestClient
  def test_put_up_for_resale
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    res = @seatsio.events.put_up_for_resale(event.key, %w(A-1 A-2))

    a1_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1').status
    a2_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-2').status
    a3_status = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-3').status

    assert_equal(Seatsio::EventObjectInfo::RESALE, a1_status)
    assert_equal(Seatsio::EventObjectInfo::RESALE, a2_status)
    assert_equal(Seatsio::EventObjectInfo::FREE, a3_status)

    assert_equal(res.objects.keys.sort, ['A-1', 'A-2'])
  end
end
