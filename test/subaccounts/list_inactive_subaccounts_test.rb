require 'test_helper'
require 'util'

class ListInactiveSubaccountsTest < SeatsioTestClient
  def test_list_inactive_subaccounts
    subaccount1 = @seatsio.subaccounts.create
    subaccount2 = @seatsio.subaccounts.create
    subaccount3 = @seatsio.subaccounts.create

    @seatsio.subaccounts.deactivate id: subaccount1.id
    @seatsio.subaccounts.deactivate id: subaccount3.id
  
    inactive_subaccounts = @seatsio.subaccounts.inactive
    assert_equal([subaccount3.id, subaccount1.id], inactive_subaccounts.collect {|subaccount| subaccount.id})
  end
end
