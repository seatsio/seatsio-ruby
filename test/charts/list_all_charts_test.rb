require 'test_helper'
require 'util'

class ListAllChartsTest < SeatsioTestClient
  def test_all
    chart1 = @seatsio.charts.create
    chart2 = @seatsio.charts.create
    chart3 = @seatsio.charts.create

    charts = @seatsio.charts.list

    keys = charts.collect {|chart| chart.key}

    assert_includes(keys, chart1.key)
    assert_includes(keys, chart2.key)
    assert_includes(keys, chart3.key)
  end

  def test_filter
    chart1 = @seatsio.charts.create name: 'some stadium'
    chart2 = @seatsio.charts.create name: 'a theatre'
    chart3 = @seatsio.charts.create name: 'some other stadium'

    charts = @seatsio.charts.list chart_filter: 'stadium'

    keys = charts.collect {|chart| chart.key}

    assert_equal([chart3.key, chart1.key], keys)
  end

  def test_tag
    chart1 = chart_with_tag(nil, 'tag1')
    chart2 = @seatsio.charts.create
    chart3 = chart_with_tag(nil, 'tag1')

    charts = @seatsio.charts.list tag: 'tag1'

    keys = charts.collect {|chart| chart.key}
    assert_equal([chart3.key, chart1.key], keys)
  end

  def test_tag_and_filter
    chart1 = chart_with_tag('some stadium', 'tag1')
    chart2 = chart_with_tag(nil, 'tag1')
    chart3 = chart_with_tag('some other stadium')
    chart4 = @seatsio.charts.create

    charts = @seatsio.charts.list chart_filter: 'stadium', tag: 'tag1'

    keys = charts.collect {|chart| chart.key}
    assert_equal([chart1.key], keys)
  end

  def test_expand_all
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    event2 = @seatsio.events.create chart_key: chart.key

    retrieved_charts = @seatsio.charts.list(expand_events: true, expand_validation: true, expand_venue_type: true).to_a

    assert_instance_of(Seatsio::Event, retrieved_charts[0].events[0])

    event_ids = retrieved_charts[0].events.collect {|event| event.id}
    assert_equal([event2.id, event1.id], event_ids)
    assert_equal('MIXED', retrieved_charts[0].venue_type)
    assert_not_nil(retrieved_charts[0].validation)
  end

  def test_expand_none
    chart = @seatsio.charts.create
    event1 = @seatsio.events.create chart_key: chart.key
    event2 = @seatsio.events.create chart_key: chart.key

    retrieved_charts = @seatsio.charts.list.to_a

    assert_nil(retrieved_charts[0].events)
    assert_nil(retrieved_charts[0].validation)
    assert_nil(retrieved_charts[0].venue_type)
  end

  def test_without_charts
    charts = @seatsio.charts.list.to_a

    assert_equal([], charts)
  end

  def test_chart_amount
    30.times do
      @seatsio.charts.create
    end

    retrieved_charts = @seatsio.charts.list().to_a
    assert_equal(30, retrieved_charts.size)
  end

  private

  def chart_with_tag(name = nil, tag = nil)
    return unless tag
    chart = @seatsio.charts.create name: name
    @seatsio.charts.add_tag(chart.key, tag)
    chart
  end
end
