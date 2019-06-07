require 'test_helper'
require 'util'

class MarkObjectsAsNotForSaleTest < SeatsioTestClient
  def test_objects_and_categories
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.mark_as_not_for_sale key: event.key, objects: %w(o1 o2), categories: %w(cat1 cat2)

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(false, retrieved_event.for_sale_config.for_sale)
    assert_equal(["o1", "o2"], retrieved_event.for_sale_config.objects)
    assert_equal(["cat1", "cat2"], retrieved_event.for_sale_config.categories)
  end

  def test_objects
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.mark_as_not_for_sale key: event.key, objects: ["o1", "o2"]

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(false, retrieved_event.for_sale_config.for_sale)
    assert_equal(["o1", "o2"], retrieved_event.for_sale_config.objects)
    assert_equal([], retrieved_event.for_sale_config.categories)
  end

  def test_categories
    chart = @seatsio.charts.create
    event = @seatsio.events.create chart_key: chart.key

    @seatsio.events.mark_as_not_for_sale key: event.key, categories: ["cat1", "cat2"]

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(false, retrieved_event.for_sale_config.for_sale)
    assert_equal([], retrieved_event.for_sale_config.objects)
    assert_equal(["cat1", "cat2"], retrieved_event.for_sale_config.categories)
  end
end
