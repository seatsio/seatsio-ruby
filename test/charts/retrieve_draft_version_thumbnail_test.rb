require 'test_helper'
require 'util'

class RetrieveDraftVersionThumbnailTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_retrieve_draft_version_thumbnail
    chart = @seatsio.client.charts.create
    @seatsio.client.events.create(chart.key)
    @seatsio.client.charts.update(chart.key, 'newname')

    thumbnail = @seatsio.client.charts.retrieve_draft_version_thumbnail(chart.key)
    assert_match(/<!DOCTYPE svg/, thumbnail)
  end
end
