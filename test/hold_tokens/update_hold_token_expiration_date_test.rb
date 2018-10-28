require 'test_helper'
require 'util'

class UpdateHoldTokenExpirationDateTest < SeatsioTestClient
  def test_update_hold_token_expiration_date
    hold_token = @seatsio.hold_tokens.create
    now = Time.now

    updated_hold_token = @seatsio.hold_tokens.expire_in_minutes hold_token: hold_token.hold_token, expires_in_minutes: 30
    assert_equal(hold_token.hold_token, updated_hold_token.hold_token)

    now_plus_29 = now + 29 * 60
    now_plus_31 = now + 31 * 60

    assert_instance_of(Time, updated_hold_token.expires_at)
    assert_between(updated_hold_token.expires_at, now_plus_29, now_plus_31)
    assert_between(updated_hold_token.expires_in_seconds, 29 * 60, 30 * 60)
  end
end
