require 'test_helper'
require 'util'

class RetrieveHoldTokenTest < SeatsioTestClient
  def test_retrieve_hold_token
    hold_token = @seatsio.hold_tokens.create

    retrieved_hold_token = @seatsio.hold_tokens.retrieve hold_token: hold_token.hold_token
    assert_equal(hold_token.hold_token, retrieved_hold_token.hold_token)
    assert_equal(hold_token.expires_at, retrieved_hold_token.expires_at)
    assert_between(retrieved_hold_token.expires_in_seconds, 14 * 60, 15 * 60)
  end
end
