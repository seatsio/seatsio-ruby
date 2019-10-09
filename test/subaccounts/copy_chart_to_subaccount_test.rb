require 'test_helper'
require 'util'

class CopyChartToSubaccountTest < SeatsioTestClient
  def test_copy_chart_to_subaccount
    from_subaccount = @seatsio.subaccounts.create
    chart = Seatsio::Client.new(from_subaccount.secret_key, nil, 'https://api-staging.seatsio.net').charts.create name: 'aChart'
    to_subaccount = @seatsio.subaccounts.create

    copied_chart = @seatsio.subaccounts.copy_chart_to_subaccount from_id: from_subaccount.id, to_id: to_subaccount.id, chart_key: chart.key
    assert_equal('aChart', copied_chart.name)

    retrieved_chart = Seatsio::Client.new(to_subaccount.secret_key, nil, 'https://api-staging.seatsio.net').charts.retrieve(copied_chart.key)
    assert_equal('aChart', retrieved_chart.name)
  end
end
