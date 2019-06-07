require 'test_helper'
require 'util'

class UpdateExtraDatasTest < SeatsioTestClient
  def test_update_extra_datas
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key
    extra_data1 = {'foo1' => 'bar1'}
    extra_data2 = {'foo2' => 'bar2'}

    @seatsio.events.update_extra_datas key: event.key, extra_data: {'A-1': extra_data1, 'A-2': extra_data2}

    object_status1 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-1'
    assert_equal(extra_data1, object_status1.extra_data)

    object_status2 = @seatsio.events.retrieve_object_status key: event.key, object_key: 'A-2'
    assert_equal(extra_data2, object_status2.extra_data)
  end
end
