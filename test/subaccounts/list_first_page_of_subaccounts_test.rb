require 'test_helper'
require 'util'

class ListFirstPageOfSubaccountsTest < SeatsioTestClient
  def test_all_on_first_page
    subaccount1 = @seatsio.subaccounts.create
    subaccount2 = @seatsio.subaccounts.create
    subaccount3 = @seatsio.subaccounts.create

    subaccounts = @seatsio.subaccounts.list.first_page

    assert_equal([subaccount3.id, subaccount2.id, subaccount1.id, @subaccount['id']], subaccounts.collect {|subaccount| subaccount.id})
    assert_nil(subaccounts.next_page_starts_after)
    assert_nil(subaccounts.previous_page_ends_before)
  end

  def test_some_on_first_page
    subaccount1 = @seatsio.subaccounts.create
    subaccount2 = @seatsio.subaccounts.create
    subaccount3 = @seatsio.subaccounts.create

    subaccounts = @seatsio.subaccounts.list.first_page(2)
    assert_equal([subaccount3.id, subaccount2.id], subaccounts.collect {|subaccount| subaccount.id})
    assert_equal(subaccount2.id, subaccounts.next_page_starts_after)
    assert_nil(subaccounts.previous_page_ends_before)
  end
end
