require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class DeleteEventTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_delete_event
    chart = @seatsio.charts.create
    event = @seatsio.events.create(chart.key)

    @seatsio.events.delete(event.key)

    assert_raises(Seatsio::Exception::NotFoundException) do
      @seatsio.events.retrieve(event.key)
    end
  end
end
