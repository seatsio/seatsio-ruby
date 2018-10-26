require 'test_helper'
require 'util'

class MarkObjectsAsForSaleTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end


  def test_objects_and_categories
    chart = @seatsio.charts.create
    event = @seatsio.events.create(chart.key)
  
    @seatsio.events.mark_as_for_sale(event.key, %w(o1 o2), %w(cat1 cat2))
  
    retrieved_event = @seatsio.events.retrieve(event.key)
    assert_equal(true, retrieved_event.for_sale_config.for_sale)
    assert_equal(%w(o1 o2), retrieved_event.for_sale_config.objects)
    assert_equal(%w(cat1 cat2), retrieved_event.for_sale_config.categories)
  end
  
  def test_objects
    chart = @seatsio.charts.create
    event = @seatsio.events.create(chart.key)
  
    @seatsio.events.mark_as_for_sale(event.key, %w(o1 o2))
  
    retrieved_event = @seatsio.events.retrieve(event.key)
    assert_equal(true, retrieved_event.for_sale_config.for_sale)
    assert_equal(%w(o1 o2), retrieved_event.for_sale_config.objects)
    assert_equal([], retrieved_event.for_sale_config.categories)
  end
  
  def test_categories
    chart = @seatsio.charts.create
    event = @seatsio.events.create(chart.key)
  
    @seatsio.events.mark_as_for_sale(event.key, nil, %w(cat1 cat2))
  
    retrieved_event = @seatsio.events.retrieve(event.key)

    assert_instance_of(Seatsio::Domain::ForSaleConfig, retrieved_event.for_sale_config)
    assert_equal(true, retrieved_event.for_sale_config.for_sale)
    assert_equal([], retrieved_event.for_sale_config.objects)
    assert_equal(%w(cat1 cat2), retrieved_event.for_sale_config.categories)
  end
end
