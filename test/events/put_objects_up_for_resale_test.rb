require 'test_helper'
require 'util'
require 'seatsio/domain'

class PutObjectsUpForResaleTest < SeatsioTestClient
  def test_put_up_for_resale
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    res = @seatsio.events.put_up_for_resale(event.key, %w(A-1 A-2), resale_listing_id: 'listing1')

    a1_info = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-1')
    a2_info = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-2')
    a3_info = @seatsio.events.retrieve_object_info(key: event.key, label: 'A-3')

    assert_equal(Seatsio::EventObjectInfo::RESALE, a1_info.status)
    assert_equal('listing1', a1_info.resale_listing_id)
    assert_equal(Seatsio::EventObjectInfo::RESALE, a2_info.status)
    assert_equal('listing1', a2_info.resale_listing_id)
    assert_equal(Seatsio::EventObjectInfo::FREE, a3_info.status)

    assert_equal(res.objects.keys.sort, ['A-1', 'A-2'])
  end
end
