require 'test_helper'
require 'util'

class UpdateExtraDataTest < SeatsioTestClient
  def test_update_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data = {"foo" => "bar"}

    @seatsio.events.update_extra_data key: event.key, object: 'A-1', extra_data: extra_data

    object_info = @seatsio.events.retrieve_object_info key: event.key, label: 'A-1'
    assert_equal(extra_data, object_info.extra_data)
  end
end
