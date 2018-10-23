require 'test_helper'
require 'util'

class CreateChartTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_default_parameters
    chart = @seatsio.charts.create

    assert_instance_of(Seatsio::Domain::Chart, chart)
    assert_operator(chart.id, :>, 0)
    assert chart.key != ''
    assert_equal('NOT_USED', chart.status)
    assert_equal('Untitled chart', chart.name)
    assert chart.published_version_thumbnail_url != ''
    assert_nil(chart.draft_version_thumbnail_url)
    assert_nil(chart.events)
    assert_empty(chart.tags)
    assert_equal(false, chart.archived)

    drawing = @seatsio.charts.retrieve_published_version(chart.key)
    assert_equal('MIXED', drawing.venue_type)
    assert_empty(drawing.categories.list)
  end

  def test_name
    chart = @seatsio.charts.create('aChart')
    assert_equal('aChart', chart.name)

    drawing = @seatsio.charts.retrieve_published_version(chart.key)
    assert_equal('MIXED', drawing.venue_type)
    assert_empty(drawing.categories.list)
  end

  def test_venue_type
    chart = @seatsio.charts.create(nil, 'BOOTHS')
    assert_equal('Untitled chart', chart.name)

    drawing = @seatsio.charts.retrieve_published_version(chart.key)
    assert_equal('BOOTHS', drawing.venue_type)
    assert_empty(drawing.categories.list)
  end

  def test_categories
    categories = [
        {:key => 1, :label => 'Category 1', :color => '#aaaaaa'},
        {:key => 2, :label => 'Category 2', :color => '#bbbbbb'}
    ]

    chart = @seatsio.charts.create(nil, nil, categories)
    assert_equal('Untitled chart', chart.name)

    drawing = @seatsio.charts.retrieve_published_version(chart.key)
    assert_equal('MIXED', drawing.venue_type)
    assert_includes(drawing.categories.list, {'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa'})
    assert_includes(drawing.categories.list, {'key' => 2, 'label' => 'Category 2', 'color' => '#bbbbbb'})
  end
end
