require 'test_helper'
require 'util'

class ActivateWorkspaceTest < SeatsioTestClient
  def test_activate
    workspace = @seatsio.workspaces.create name: 'a ws'
    @seatsio.workspaces.deactivate key: workspace.key

    @seatsio.workspaces.activate key: workspace.key

    retrieved_workspace = @seatsio.workspaces.retrieve key: workspace.key
    assert_true(retrieved_workspace.is_active)
  end
end
