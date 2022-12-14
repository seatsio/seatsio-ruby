require 'test_helper'
require 'util'

class ManageCategoriesTest < SeatsioTestClient
  def test_add_category
    categories = [
      { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false }
    ]
    chart = @seatsio.charts.create categories: categories

    @seatsio.charts.add_category(chart.key, { 'key' => 'cat2', 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true })
  end

  def test_remove_category
    categories = [
      { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false },
      { 'key' => 'cat2', 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true }
    ]
    chart = @seatsio.charts.create categories: categories

    @seatsio.charts.remove_category(chart.key, 'cat2')
  end
end
