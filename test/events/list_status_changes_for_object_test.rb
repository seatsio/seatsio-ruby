require 'test_helper'
require 'util'

class ListStatusChangesForObjectTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end
  
  def test_list_status_changes_for_object
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)

    @seatsio.events.change_object_status(event.key, ['A-1'], 'status1')
    @seatsio.events.change_object_status(event.key, ['A-1'], 'status2')
    @seatsio.events.change_object_status(event.key, ['A-1'], 'status3')
    @seatsio.events.change_object_status(event.key, ['A-1'], 'status4')

    status_changes = @seatsio.events.list_status_changes(event.key, 'A-1')
    assert_equal(%w(status4 status3 status2 status1), status_changes.collect {|status| status.status})
  end

end
