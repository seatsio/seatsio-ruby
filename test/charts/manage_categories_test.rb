require 'test_helper'
require 'util'

class ManageCategoriesTest < SeatsioTestClient
  def test_add_category
    categories = [
      { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false }
    ]
    chart = @seatsio.charts.create categories: categories

    @seatsio.charts.add_category(chart.key, { 'key' => 'cat2', 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true })

    retrieved_chart = @seatsio.charts.retrieve(chart.key)
    drawing = @seatsio.charts.retrieve_published_version(retrieved_chart.key)
    expected_categories = [
      { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false },
      { 'key' => 'cat2', 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true }
    ]
    assert_equal(expected_categories, drawing['categories']['list'])
  end

  def test_remove_category
    categories = [
      { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false },
      { 'key' => 'cat2', 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true }
    ]
    chart = @seatsio.charts.create categories: categories

    @seatsio.charts.remove_category(chart.key, 'cat2')

    retrieved_chart = @seatsio.charts.retrieve(chart.key)
    drawing = @seatsio.charts.retrieve_published_version(retrieved_chart.key)
    expected_categories = [
      { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false }
    ]
    assert_equal(expected_categories, drawing['categories']['list'])
  end

  def test_list_categories
    categories = [
      { 'key' => 1, 'label' => 'Category 1', 'color' => '#aaaaaa', 'accessible' => false },
      { 'key' => 'cat2', 'label' => 'Category 2', 'color' => '#bbbbbb', 'accessible' => true }
    ]
    chart = @seatsio.charts.create categories: categories

    category_list = @seatsio.charts.list_categories(chart.key)
    category_list.each_with_index do |category, index|
      assert_equal(categories[index]['key'], category.key)
    end
  end
end
