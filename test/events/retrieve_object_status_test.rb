require 'test_helper'
require 'util'

class RetrieveObjectStatusTest < SeatsioTestClient
  def test_retrieve_object_status
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    object_status = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(Seatsio::Domain::ObjectStatus::FREE, object_status.status)
  end
end
