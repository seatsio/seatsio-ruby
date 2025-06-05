require 'test_helper'
require 'util'
require 'securerandom'

class RemoveTicketBuyerIdsTest < SeatsioTestClient

  def test_can_remove_ticket_buyer_ids
    ticketBuyerId1 = SecureRandom.uuid
    ticketBuyerId2 = SecureRandom.uuid
    ticketBuyerId3 = SecureRandom.uuid
    @seatsio.ticket_buyers.add([ticketBuyerId1, ticketBuyerId2])

    result = @seatsio.ticket_buyers.remove([ticketBuyerId1, ticketBuyerId2, ticketBuyerId3])
    assert_equal(2, result.removed.size)
    assert_includes(result.removed, ticketBuyerId1)
    assert_includes(result.removed, ticketBuyerId2)
    assert_equal(1, result.not_present.size)
    assert_includes(result.not_present, ticketBuyerId3)
  end

  def test_null_does_not_get_removed
    ticketBuyerId1 = SecureRandom.uuid
    ticketBuyerId2 = SecureRandom.uuid
    ticketBuyerId3 = SecureRandom.uuid
    @seatsio.ticket_buyers.add([ticketBuyerId1, ticketBuyerId2, ticketBuyerId3])

    result = @seatsio.ticket_buyers.remove([ticketBuyerId1, nil])
    assert_equal(1, result.removed.size)
    assert_includes(result.removed, ticketBuyerId1)
    assert_empty(result.not_present)
  end

end
