require 'test_helper'
require 'util'

class AddWorkspaceSecretKeyTest < SeatsioTestClient
  def test_add_secret_key
    workspace = @seatsio.workspaces.create name: 'a ws'

    new_secret_key = @seatsio.workspaces.add_secret_key key: workspace.key

    assert_not_blank(new_secret_key)
    assert_not_equal(new_secret_key, workspace.secret_key)
    retrieved_workspace = @seatsio.workspaces.retrieve key: workspace.key
    assert_equal([workspace.secret_key, new_secret_key], retrieved_workspace.secret_keys)
  end
end
