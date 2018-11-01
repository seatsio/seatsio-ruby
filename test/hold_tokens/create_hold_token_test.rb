require 'test_helper'
require 'util'

class CreateHoldTokenTest < SeatsioTestClient
  def test_create_hold_token
    now = Time.now
    hold_token = @seatsio.hold_tokens.create
    assert_not_nil(hold_token.hold_token)
    assert_instance_of(Time, hold_token.expires_at)
    assert_between(hold_token.expires_at, now + 14 * 60, now + 16 * 60)
    assert_between(hold_token.expires_in_seconds, 14 * 60, 15 * 60)
  end
  
  def test_expires_in_minutes
    now = Time.now
    hold_token = @seatsio.hold_tokens.create expires_in_minutes: 5

    assert_not_nil(hold_token.hold_token)
    assert_instance_of(Time, hold_token.expires_at)
    assert_between(hold_token.expires_at, now + 4 * 60, now + 6 * 60)
    assert_between(hold_token.expires_in_seconds, 4 * 60, 5 * 60)
  end
end
