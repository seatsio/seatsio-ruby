require 'test_helper'
require 'util'

class MarkObjectsAsNotForSaleTest < SeatsioTestClient
  def test_objects_and_categories
    chart_key = create_test_chart
    event = @seatsio.events.create chart_key: chart_key

    @seatsio.events.mark_as_not_for_sale key: event.key, objects: %w(o1 o2), area_places: { 'GA1' => 3 }, categories: %w(cat1 cat2)

    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_equal(false, retrieved_event.for_sale_config.for_sale)
    assert_equal(["o1", "o2"], retrieved_event.for_sale_config.objects)
    assert_equal({ 'GA1' => 3 }, retrieved_event.for_sale_config.area_places)
    assert_equal(["cat1", "cat2"], retrieved_event.for_sale_config.categories)
  end
end
