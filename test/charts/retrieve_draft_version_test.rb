require 'test_helper'
require 'util'

class RetrieveDraftVersionTest < SeatsioTestClient
  def test_retrieve_draft_version
    chart = @seatsio.charts.create
    @seatsio.events.create chart_key: chart.key
    @seatsio.charts.update key: chart.key, new_name: 'newname'

    draft_drawing = @seatsio.charts.retrieve_draft_version(chart.key)

    assert_equal('newname', draft_drawing['name'])
  end
end
