require 'test_helper'
require 'util'

class WorkspaceKeyAuthenticationTest < SeatsioTestClient
  def test_client_takes_optional_workspace_key
    subaccount = @seatsio.subaccounts.create

    subaccount_client = Seatsio::Client.new(@user['secretKey'], subaccount.workspace_key, "https://api-staging.seatsio.net")
    hold_token = subaccount_client.hold_tokens.create

    assert_equal(subaccount.workspace_key, hold_token.workspace_key)
  end
end
