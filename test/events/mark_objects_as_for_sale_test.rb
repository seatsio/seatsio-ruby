require 'test_helper'
require 'util'

class MarkObjectsAsForSaleTest < SeatsioTestClient
  def test_objects_and_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.mark_as_for_sale key: event.key, objects: %w(o1 o2), area_places: { 'GA1' => 3 }, categories: %w(cat1 cat2)

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(true, retrieved_event.for_sale_config.for_sale)
    assert_equal(%w(o1 o2), retrieved_event.for_sale_config.objects)
    assert_equal({ 'GA1' => 3 }, retrieved_event.for_sale_config.area_places)
    assert_equal(%w(cat1 cat2), retrieved_event.for_sale_config.categories)
  end

  def test_objects
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.mark_as_for_sale key: event.key, objects: %w(o1 o2)

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(true, retrieved_event.for_sale_config.for_sale)
    assert_equal(%w(o1 o2), retrieved_event.for_sale_config.objects)
    assert_equal([], retrieved_event.for_sale_config.categories)
  end

  def test_categories
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.mark_as_for_sale key: event.key, categories: %w(cat1 cat2)

    retrieved_event = @seatsio.events.retrieve key: event.key

    assert_instance_of(Seatsio::ForSaleConfig, retrieved_event.for_sale_config)
    assert_equal(true, retrieved_event.for_sale_config.for_sale)
    assert_equal([], retrieved_event.for_sale_config.objects)
    assert_equal(%w(cat1 cat2), retrieved_event.for_sale_config.categories)
  end
end
