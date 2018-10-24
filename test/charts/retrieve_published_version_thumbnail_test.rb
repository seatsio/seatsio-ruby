require 'test_helper'
require 'util'

class RetrievePublishedVersionThumbnailTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_retrieve_published_version_thumbnail
    chart = @seatsio.charts.create
    thumbnail = @seatsio.charts.retrieve_published_version_thumbnail(chart.key)
    assert_match(/<!DOCTYPE svg/, thumbnail)
  end
end
