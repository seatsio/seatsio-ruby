require 'test_helper'
require 'util'

class RetrieveChartTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_retrieve_chart
    chart = @seatsio.charts.create
    @seatsio.charts.add_tag(chart.key, 'tag1')
    @seatsio.charts.add_tag(chart.key, 'tag2')

    retrieved_chart = @seatsio.charts.retrieve(chart.key)

    assert_instance_of(Seatsio::Domain::Chart, retrieved_chart)
    assert_operator(retrieved_chart.id, :!=, 0)
    assert(retrieved_chart.key != nil) # assert_that(retrieved_chart.key).is_not_blank()
    assert_equal('NOT_USED', retrieved_chart.status)
    assert_equal('Untitled chart', retrieved_chart.name)
    assert(retrieved_chart.published_version_thumbnail_url != nil)
    assert_nil(retrieved_chart.draft_version_thumbnail_url)
    assert_nil(retrieved_chart.events)
    assert_equal(%w(tag2 tag1), retrieved_chart.tags)
    assert_equal(false, retrieved_chart.archived)
  end

  def test_with_events
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create(chart.key)
    event2 = @seatsio.events.create(chart.key)

    retrieved_chart = @seatsio.charts.retrieve_with_events(chart.key)
    
    retrieved_chart_ids = retrieved_chart.events.collect {|c| c.id}
    assert_equal([event2.id, event1.id], retrieved_chart_ids)
  end
end
