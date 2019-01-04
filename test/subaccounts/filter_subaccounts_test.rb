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

  def test_filter_subaccounts_with_no_results
    subaccounts = @seatsio.subaccounts.list filter: "test-/@/2"
    assert_equal([], subaccounts.to_a )
  end

  def test_filter_all_on_first_page
    subaccount1 = @seatsio.subaccounts.create(name: "test-/@/1")
    subaccount2 = @seatsio.subaccounts.create(name: "test-/@/2")
    subaccount3 = @seatsio.subaccounts.create(name: "test-/@/3")

    subaccounts = @seatsio.subaccounts.list(filter: "test-/@/2").first_page

    assert_equal([subaccount2.id], subaccounts.collect {|subaccount| subaccount.id})
    assert_nil(subaccounts.next_page_starts_after)
    assert_nil(subaccounts.previous_page_ends_before)
  end

  def test_filter_with_previous_page
    subaccount1 = @seatsio.subaccounts.create(name: "test-/@/11")
    subaccount2 = @seatsio.subaccounts.create(name: "test-/@/12")
    subaccount3 = @seatsio.subaccounts.create(name: "test-/@/33")
    subaccount4 = @seatsio.subaccounts.create(name: "test-/@/4")
    subaccount5 = @seatsio.subaccounts.create(name: "test-/@/5")
    subaccount6 = @seatsio.subaccounts.create(name: "test-/@/6")
    subaccount7 = @seatsio.subaccounts.create(name: "test-/@/7")
    subaccount8 = @seatsio.subaccounts.create(name: "test-/@/8")

    subaccounts = @seatsio.subaccounts.list(filter: "test-/@/1").page_after(subaccount3.id)

    assert_equal([subaccount2.id, subaccount1.id], subaccounts.collect {|subaccount| subaccount.id})
    assert_nil(subaccounts.next_page_starts_after)
    assert_equal(subaccount2.id, subaccounts.previous_page_ends_before)
  end

  def test_filter_with_next_page
    subaccount1 = @seatsio.subaccounts.create(name: "test-/@/11")
    subaccount2 = @seatsio.subaccounts.create(name: "test-/@/12")
    subaccount3 = @seatsio.subaccounts.create(name: "test-/@/13")
    subaccount4 = @seatsio.subaccounts.create(name: "test-/@/4")
    subaccount5 = @seatsio.subaccounts.create(name: "test-/@/5")
    subaccount6 = @seatsio.subaccounts.create(name: "test-/@/6")
    subaccount7 = @seatsio.subaccounts.create(name: "test-/@/7")
    subaccount8 = @seatsio.subaccounts.create(name: "test-/@/8")

    subaccounts = @seatsio.subaccounts.list(filter: "test-/@/1").page_before(subaccount1.id)

    assert_equal([subaccount3.id, subaccount2.id], subaccounts.collect {|subaccount| subaccount.id})
    assert_equal(subaccount2.id, subaccounts.next_page_starts_after)
    assert_nil(subaccounts.previous_page_ends_before)
  end
end
