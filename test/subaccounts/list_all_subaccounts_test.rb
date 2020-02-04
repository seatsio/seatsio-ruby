require 'test_helper'
require 'util'

class ListAllSubaccountsTest < SeatsioTestClient
  def test_list_all_subaccounts
    subaccount1 = @seatsio.subaccounts.create
    subaccount2 = @seatsio.subaccounts.create
    subaccount3 = @seatsio.subaccounts.create

    subaccounts = @seatsio.subaccounts.list
    assert_equal([subaccount3.id, subaccount2.id, subaccount1.id, @user["mainWorkspace"]["primaryUser"]["id"]], subaccounts.collect {|subaccount| subaccount.id})
  end
end
