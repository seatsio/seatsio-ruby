require 'test_helper'
require 'util'

class AccountIdAuthenticationTest < SeatsioTestClient
  def test_client_takes_optional_account_id
    subaccount = @seatsio.subaccounts.create

    subaccount_client = Seatsio::Client.new(@user['secretKey'], subaccount.account_id, "https://api-staging.seatsio.net")
    hold_token = subaccount_client.hold_tokens.create

    assert_equal(subaccount.account_id, hold_token.account_id)
  end
end
