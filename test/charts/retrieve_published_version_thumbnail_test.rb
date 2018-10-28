require 'test_helper'
require 'util'

class RetrievePublishedVersionThumbnailTest < SeatsioTestClient
  def test_retrieve_published_version_thumbnail
    chart = @seatsio.charts.create
    thumbnail = @seatsio.charts.retrieve_published_version_thumbnail(chart.key)
    assert_match(/<!DOCTYPE svg/, thumbnail)
  end
end
