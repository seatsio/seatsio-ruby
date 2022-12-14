require  "test_helper"
require "util"

class CopyChartToSubaccountTest < SeatsioTestClient
  def test_copy_to_subaccount
    chart = @seatsio.charts.create name: 'my chart', venue_type: 'BOOTHS'
    subaccount = @seatsio.subaccounts.create

    copied_chart = @seatsio.charts.copy_to_subaccount(chart.key, subaccount.id)

    subaccount_client = test_client(subaccount.secret_key, nil)
    assert_equal("my chart", copied_chart.name)

    retrieved_chart = subaccount_client.charts.retrieve(copied_chart.key)
    assert_equal("my chart", retrieved_chart.name)
  end

end
