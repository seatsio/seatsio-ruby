require 'test_helper'
require 'util'
require 'seatsio/domain'

class ChartReportsTest < SeatsioTestClient

  def test_multiple_events
    chart_key = create_test_chart
    event_creation_params = [{}, {}]
    events = @seatsio.events.create_multiple(key: chart_key, event_creation_params: event_creation_params)

    assert_equal(2, events.length)
    events.each {|e| assert_not_nil(e.key)}

  end

end