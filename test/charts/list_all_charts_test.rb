require 'test_helper'
require 'util'

class ListAllChartsTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_all
    chart1 = @seatsio.client.charts.create
    chart2 = @seatsio.client.charts.create
    chart3 = @seatsio.client.charts.create

    charts = @seatsio.client.charts.list

    keys = charts.collect {|chart| chart.key}

    assert_includes(keys, chart1.key)
    assert_includes(keys, chart2.key)
    assert_includes(keys, chart3.key)
  end

  def test_filter
    chart1 = @seatsio.client.charts.create('some stadium')
    chart2 = @seatsio.client.charts.create('a theatre')
    chart3 = @seatsio.client.charts.create('some other stadium')

    charts = @seatsio.client.charts.list('stadium')

    keys = charts.collect {|chart| chart.key}

    assert_equal([chart3.key, chart1.key], keys)
  end

  def test_tag
    chart1 = chart_with_tag(nil, 'tag1')
    chart2 = @seatsio.client.charts.create
    chart3 = chart_with_tag(nil, 'tag1')

    charts = @seatsio.client.charts.list(nil, 'tag1')

    keys = charts.collect {|chart| chart.key}
    assert_equal([chart3.key, chart1.key], keys)
  end

  def test_tag_and_filter
    chart1 = chart_with_tag('some stadium', 'tag1')
    chart2 = chart_with_tag(nil, 'tag1')
    chart3 = chart_with_tag('some other stadium')
    chart4 = @seatsio.client.charts.create

    charts = @seatsio.client.charts.list('stadium', 'tag1')

    keys = charts.collect {|chart| chart.key}
    assert_equal([chart1.key], keys)
  end

  def test_expand
    chart = @seatsio.client.charts.create
    event1 = @seatsio.client.events.create(chart.key)
    event2 = @seatsio.client.events.create(chart.key)

    retrieved_charts = @seatsio.client.charts.list(nil, nil, true).to_a

    assert_instance_of(Seatsio::Domain::Event, retrieved_charts[0].events[0])

    event_ids = retrieved_charts[0].events.collect {|event| event.id}
    assert_equal([event2.id, event1.id], event_ids)
      #assert_that(retrieved_charts[0].events).extracting("id").contains_exactly(event2.id, event1.id)

  end

  private

  def chart_with_tag(name = nil, tag = nil)
    return unless tag
    chart = @seatsio.client.charts.create(name)
    @seatsio.client.charts.add_tag(chart.key, tag)
    chart
  end
end