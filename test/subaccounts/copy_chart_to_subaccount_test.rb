require 'test_helper'
require 'util'

class CopyChartToSubaccountTest < SeatsioTestClient
  def test_copy_chart_to_subaccount
    from_subaccount = @seatsio.subaccounts.create
    chart = test_client(from_subaccount.secret_key, nil).charts.create name: 'aChart'
    to_subaccount = @seatsio.subaccounts.create

    copied_chart = @seatsio.subaccounts.copy_chart_to_subaccount from_id: from_subaccount.id, to_id: to_subaccount.id, chart_key: chart.key
    assert_equal('aChart', copied_chart.name)

    retrieved_chart = test_client(to_subaccount.secret_key, nil).charts.retrieve(copied_chart.key)
    assert_equal('aChart', retrieved_chart.name)
  end
end
