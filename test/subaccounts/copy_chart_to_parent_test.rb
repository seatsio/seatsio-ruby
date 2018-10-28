require 'test_helper'
require 'util'

class CopyChartToParentTest < SeatsioTestClient
  def test_copy_chart_to_parent
    subaccount = @seatsio.subaccounts.create
    chart = Seatsio::Client.new(subaccount.secret_key, 'https://api-staging.seatsio.net').charts.create('aChart')
  
    copied_chart = @seatsio.subaccounts.copy_chart_to_parent id: subaccount.id, chart_key: chart.key
    assert_equal('aChart', copied_chart.name)

    retrieved_chart = @seatsio.charts.retrieve(copied_chart.key)
    assert_equal('aChart', retrieved_chart.name)
  end
end
