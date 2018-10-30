require 'test_helper'
require 'util'

class MarkEverythingAsForSaleTest < SeatsioTestClient
  def test_mask_everything_as_for_sale
    chart = @seatsio.charts.create
    event = @seatsio.events.create key: chart.key
    @seatsio.events.mark_as_not_for_sale key: event.key, objects: %w(o1 o2), categories: %w(cat1 cat2)
  
    @seatsio.events.mark_everything_as_for_sale key: event.key
  
    retrieved_event = @seatsio.events.retrieve key: event.key
    assert_nil(retrieved_event.for_sale_config)
  end
end
