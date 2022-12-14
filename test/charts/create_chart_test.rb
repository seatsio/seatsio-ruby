require 'test_helper'
require 'util'

class CreateChartTest < SeatsioTestClient
  def test_default_parameters
    chart = @seatsio.charts.create

    assert_instance_of(Seatsio::Chart, chart)
    assert_operator(chart.id, :>, 0)
    assert chart.key != ''
    assert_equal('NOT_USED', chart.status)
    assert_equal('Untitled chart', chart.name)
    assert chart.published_version_thumbnail_url != ''
    assert_nil(chart.draft_version_thumbnail_url)
    assert_nil(chart.events)
    assert_empty(chart.tags)
    assert_equal(false, chart.archived)
  end

  def test_name
    chart = @seatsio.charts.create name: 'aChart'
    assert_equal('aChart', chart.name)
  end

  def test_venue_type
    chart = @seatsio.charts.create venue_type: 'BOOTHS'
    assert_equal('Untitled chart', chart.name)
  end

  def test_categories
    categories = [
        {:key => 1, :label => 'Category 1', :color => '#aaaaaa'},
        {:key => 2, :label => 'Category 2', :color => '#bbbbbb', :accessible => true}
    ]
    chart = @seatsio.charts.create categories: categories
    assert_equal('Untitled chart', chart.name)
  end
end
