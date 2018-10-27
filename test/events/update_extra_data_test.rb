require 'test_helper'
require 'util'

class UpdateExtraDataTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_update_extra_data
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)
    extra_data = {"foo" => "bar"}
  
    @seatsio.events.update_extra_data(event.key, "A-1", extra_data)
  
    object_status = @seatsio.events.retrieve_object_status(event.key, "A-1")
    assert_equal(extra_data, object_status.extra_data)
  end
end
