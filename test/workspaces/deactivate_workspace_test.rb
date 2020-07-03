require 'test_helper'
require 'util'

class DeactivateWorkspaceTest < SeatsioTestClient
  def test_deactivate
    workspace = @seatsio.workspaces.create name: 'a ws'

    @seatsio.workspaces.deactivate key: workspace.key

    retrieved_workspace = @seatsio.workspaces.retrieve key: workspace.key
    assert_false(retrieved_workspace.is_active)
  end
end
