require 'test_helper'
require 'util'

class ListEventLogItemsTest < SeatsioTestClient
  def test_list_all_event_log_items
    chart = @seatsio.charts.create
    @seatsio.charts.update key: chart.key, new_name: 'a chart'

    sleep(2)

    event_log_items = @seatsio.event_log.list

    types = event_log_items.collect { |event_log_item| event_log_item.type }
    assert_equal(%w[chart.created chart.published], types)
  end

  def test_event_log_item_properties
    chart = @seatsio.charts.create

    sleep(2)

    event_log_items = @seatsio.event_log.list
    event_log_item = event_log_items.first_page.to_a[0]

    assert_equal('chart.created', event_log_item.type)
    assert_true(event_log_item.id > 0)
    assert_not_nil(event_log_item.timestamp)
    assert_equal({ "key" => chart.key, "workspaceKey" => @workspace.key }, event_log_item.data)
  end

end
