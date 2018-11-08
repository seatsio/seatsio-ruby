require 'test_helper'
require 'util'

class RetrievePublishedVersionTest < SeatsioTestClient
  def test_retrieve_published_version
    chart = @seatsio.charts.create name: 'chartName'
    published_drawing = @seatsio.charts.retrieve_published_version(chart.key)
    assert_equal('chartName', published_drawing.name)
  end
end
