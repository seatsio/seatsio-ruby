require 'test_helper'
require 'util'

class RetrieveObjectStatusTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_retrieve_object_status
    chart_key = create_test_chart
    event = @seatsio.events.create(chart_key)

    object_status = @seatsio.events.retrieve_object_status(event.key, "A-1")
    assert_equal(Seatsio::Domain::ObjectStatus::FREE, object_status.status)
  end
end
