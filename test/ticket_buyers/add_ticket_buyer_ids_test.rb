require 'test_helper'
require 'util'
require 'securerandom'

class AddTicketBuyerIdsTest < SeatsioTestClient

  def test_can_add_ticket_buyer_ids
    ticketBuyerId1 = SecureRandom.uuid
    ticketBuyerId2 = SecureRandom.uuid
    ticketBuyerId3 = SecureRandom.uuid

    result = @seatsio.ticket_buyers.add([ticketBuyerId1, ticketBuyerId2, ticketBuyerId3])
    assert_includes(result.added, ticketBuyerId1)
    assert_includes(result.added, ticketBuyerId2)
    assert_includes(result.added, ticketBuyerId3)
    assert_empty(result.already_present)
  end

  def test_can_add_ticket_buyer_ids_list_with_duplicates
    ticketBuyerId1 = SecureRandom.uuid
    ticketBuyerId2 = SecureRandom.uuid

    result = @seatsio.ticket_buyers.add([ticketBuyerId1, ticketBuyerId1, ticketBuyerId1, ticketBuyerId2, ticketBuyerId2])
    assert_includes(result.added, ticketBuyerId1)
    assert_includes(result.added, ticketBuyerId2)
    assert_equal(2, result.added.size)
    assert_empty(result.already_present)
  end

  def test_can_add_ticket_buyer_ids_same_id_does_not_get_added_twice
    ticketBuyerId1 = SecureRandom.uuid
    ticketBuyerId2 = SecureRandom.uuid

    result = @seatsio.ticket_buyers.add([ticketBuyerId1, ticketBuyerId2])
    assert_equal(2, result.added.size)
    assert_includes(result.added, ticketBuyerId1)
    assert_includes(result.added, ticketBuyerId2)
    assert_empty(result.already_present)

    second_result = @seatsio.ticket_buyers.add(ticketBuyerId1)
    assert_equal(1, second_result.already_present.size)
    assert_includes(second_result.already_present, ticketBuyerId1)
  end

  def test_can_add_ticket_buyer_ids_nil_does_not_get_added
    ticketBuyerId1 = SecureRandom.uuid

    result = @seatsio.ticket_buyers.add([ticketBuyerId1, nil])
    assert_equal(1, result.added.size)
    assert_includes(result.added, ticketBuyerId1)
    assert_empty(result.already_present)
  end

end
