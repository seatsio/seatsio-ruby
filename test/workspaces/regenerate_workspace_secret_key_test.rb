require 'test_helper'
require 'util'

class RegenerateWorkspaceSecretKeyTest < SeatsioTestClient
  def test_regenerate_secret_key
    workspace = @seatsio.workspaces.create name: 'a ws'

    new_secret_key = @seatsio.workspaces.regenerate_secret_key key: workspace.key

    assert_not_blank(new_secret_key)
    assert_not_equal(new_secret_key, workspace.secret_key)
    retrieved_workspace = @seatsio.workspaces.retrieve key: workspace.key
    assert_equal(new_secret_key, retrieved_workspace.secret_key)
  end
end
