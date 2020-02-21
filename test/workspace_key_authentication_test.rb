require 'test_helper'
require 'util'

class WorkspaceKeyAuthenticationTest < SeatsioTestClient
  def test_client_takes_optional_workspace_key
    subaccount = @seatsio.subaccounts.create

    subaccount_client = test_client(@user['secretKey'], subaccount.public_key)
    hold_token = subaccount_client.hold_tokens.create

    assert_equal(subaccount.public_key, hold_token.workspace_key)
  end
end
