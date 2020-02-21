require 'test_helper'
require 'util'
require 'seatsio/domain'

class UpdateWorkspaceTest < SeatsioTestClient

  def test_update_workspace
    workspace = @seatsio.workspaces.create name: 'my workspace'

    @seatsio.workspaces.update key: workspace.key, name: 'my ws'

    retrieved_workspace = @seatsio.workspaces.retrieve key: workspace.key
    assert_operator(retrieved_workspace.id, :!=, 0)
    assert_equal('my ws', retrieved_workspace.name)
    assert_operator(retrieved_workspace.key, :!=, nil)
    assert_operator(retrieved_workspace.secret_key, :!=, nil)
    assert_false(retrieved_workspace.is_test)
  end
end
