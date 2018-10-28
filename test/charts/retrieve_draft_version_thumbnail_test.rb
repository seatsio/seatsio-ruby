require 'test_helper'
require 'util'

class RetrieveDraftVersionThumbnailTest < SeatsioTestClient
  def test_retrieve_draft_version_thumbnail
    chart = @seatsio.charts.create
    @seatsio.events.create key: chart.key
    @seatsio.charts.update(chart.key, 'newname')

    thumbnail = @seatsio.charts.retrieve_draft_version_thumbnail(chart.key)
    assert_match(/<!DOCTYPE svg/, thumbnail)
  end
end
