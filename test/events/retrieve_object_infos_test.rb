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

  def test_holds
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    hold_token = @seatsio.hold_tokens.create
    @seatsio.events.hold event.key, 'GA1', hold_token.hold_token

    object_infos = @seatsio.events.retrieve_object_infos key: event.key, labels: ['GA1']
    expected_holds = { hold_token.hold_token => { "NO_TICKET_TYPE" => 1 } }
    assert_equal(expected_holds, object_infos['GA1'].holds)
  end
end
