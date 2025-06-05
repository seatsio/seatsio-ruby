require 'test_helper'
require 'util'
require 'securerandom'

class ListAllTest < SeatsioTestClient

  def test_list_all
    ticketBuyerId1 = SecureRandom.uuid
    ticketBuyerId2 = SecureRandom.uuid
    ticketBuyerId3 = SecureRandom.uuid
    @seatsio.ticket_buyers.add([ticketBuyerId1, ticketBuyerId2, ticketBuyerId3])

    result = @seatsio.ticket_buyers.list_all
    assert_includes(result, ticketBuyerId1)
    assert_includes(result, ticketBuyerId2)
    assert_includes(result, ticketBuyerId3)
  end

end
