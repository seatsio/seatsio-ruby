require 'test_helper'
require 'util'

class ListActiveSubaccountsTest < SeatsioTestClient
  def test_list_active_subaccount
    subaccount1 = @seatsio.subaccounts.create
    subaccount2 = @seatsio.subaccounts.create
    subaccount3 = @seatsio.subaccounts.create
    @seatsio.subaccounts.deactivate id: subaccount2.id

    active_subaccounts = @seatsio.subaccounts.active
    assert_equal([subaccount3.id, subaccount1.id, @user["mainWorkspace"]["primaryUser"]["id"]], active_subaccounts.collect {|subaccount| subaccount.id})
  end
end
