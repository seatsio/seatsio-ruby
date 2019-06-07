require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class DeleteEventTest < SeatsioTestClient
  def test_delete_event
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.delete key: event.key

    assert_raises(Seatsio::Exception::NotFoundException) do
      @seatsio.events.retrieve key: event.key
    end
  end
end
