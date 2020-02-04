require 'test_helper'
require 'util'

class ListSubaccountsAfterTest < SeatsioTestClient
  def test_with_previous_page
    subaccount1 = @seatsio.subaccounts.create
    subaccount2 = @seatsio.subaccounts.create
    subaccount3 = @seatsio.subaccounts.create

    subaccounts = @seatsio.subaccounts.list.page_after(subaccount3.id)

    assert_equal([subaccount2.id, subaccount1.id, @user["mainWorkspace"]["primaryUser"]["id"]], subaccounts.collect {|subaccount| subaccount.id})
    assert_nil(subaccounts.next_page_starts_after)
    assert_equal(subaccount2.id, subaccounts.previous_page_ends_before)
  end

  def test_with_next_and_previous_pages
    subaccount1 = @seatsio.subaccounts.create
    subaccount2 = @seatsio.subaccounts.create
    subaccount3 = @seatsio.subaccounts.create

    subaccounts = @seatsio.subaccounts.list.page_after(subaccount3.id, 1)

    assert_equal([subaccount2.id], subaccounts.collect {|subaccount| subaccount.id})
    assert_equal(subaccount2.id, subaccounts.next_page_starts_after)
    assert_equal(subaccount2.id, subaccounts.previous_page_ends_before)
  end
end
