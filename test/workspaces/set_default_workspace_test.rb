require 'test_helper'
require 'util'

class SetDefaultWorkspaceTest < SeatsioTestClient
  def test_set_default
    workspace = @seatsio.workspaces.create name: 'a ws'

    @seatsio.workspaces.set_default key: workspace.key

    retrieved_workspace = @seatsio.workspaces.retrieve key: workspace.key
    assert_true(retrieved_workspace.is_default)
  end
end
