require 'test_helper'
require 'util'

class FilterSubaccountsTest < SeatsioTestClient
  def test_filter_subaccounts
    subaccount1 = @seatsio.subaccounts.create(name: "test1")
    subaccount2 = @seatsio.subaccounts.create(name: "test2")
    subaccount3 = @seatsio.subaccounts.create(name: "test3")

    subaccounts = @seatsio.subaccounts.list filter: "test2"
    assert_equal([subaccount2.id], subaccounts.collect {|subaccount| subaccount.id})
  end

  def test_filter_subaccounts_with_special_chars
    subaccount1 = @seatsio.subaccounts.create(name: "test-/@/1")
    subaccount2 = @seatsio.subaccounts.create(name: "test-/@/2")
    subaccount3 = @seatsio.subaccounts.create(name: "test-/@/3")

    subaccounts = @seatsio.subaccounts.list filter: "test-/@/2"
    assert_equal([subaccount2.id], subaccounts.collect {|subaccount| subaccount.id})
  end
end
