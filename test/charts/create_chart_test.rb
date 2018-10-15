require "test_helper"
require "util"

class CreateChartTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user["secretKey"], "https://api-staging.seatsio.net")
  end

  def test_default_parameters
    chart = @seatsio.client.charts.create

    assert_instance_of(Seatsio::Domain::Chart, chart)
    assert_operator(chart.id, :>, 0)
    assert chart.key != ""
    assert_equal("NOT_USED", chart.status)
    assert_equal("Untitled chart", chart.name)
    assert chart.published_version_thumbnail_url != ""
    assert_nil(chart.draft_version_thumbnail_url)
    assert_empty(chart.events)
    assert_empty(chart.tags)
    assert_equal(false, chart.archived)

    drawing = @seatsio.client.charts.retrieve_published_version(chart.key)
    assert_equal("MIXED", drawing.venue_type)
    assert_empty(drawing.categories.list)
  end
end