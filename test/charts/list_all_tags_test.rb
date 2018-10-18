require 'test_helper'
require 'util'

class ListAllTagsTest < Minitest::Test
  def setup
    @user = create_test_user
    @seatsio = Seatsio::Seatsio.new(@user['secretKey'], 'https://api-staging.seatsio.net')
  end

  def test_list_all_tags
    chart1 = @seatsio.client.charts.create
    @seatsio.client.charts.add_tag(chart1.key, 'tag1')
    @seatsio.client.charts.add_tag(chart1.key, 'tag2')

    chart2 = @seatsio.client.charts.create
    @seatsio.client.charts.add_tag(chart2.key, 'tag3')

    tags = @seatsio.client.charts.list_all_tags

    assert_includes(tags, 'tag1')
    assert_includes(tags, 'tag2')
    assert_includes(tags, 'tag3')
  end
end