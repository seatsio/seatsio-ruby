require 'test_helper'
require 'util'

class WorkspaceKeyAuthenticationTest < SeatsioTestClient
  def test_client_takes_optional_workspace_key
    workspace = @seatsio.workspaces.create name: 'some workspace'

    workspace_client = test_client(@user['secretKey'], workspace.key)
    hold_token = workspace_client.hold_tokens.create

    assert_equal(workspace.key, hold_token.workspace_key)
  end
end
