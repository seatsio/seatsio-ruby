require 'test_helper'
require 'util'
require 'seatsio/domain'

class RetrieveWorkspaceTest < SeatsioTestClient

  def test_retrieve_workspace
    workspace = @seatsio.workspaces.create name: 'my workspace'

    retrieved_workspace = @seatsio.workspaces.retrieve key: workspace.key
    assert_operator(retrieved_workspace.id, :!=, 0)
    assert_equal('my workspace', retrieved_workspace.name)
    assert_operator(retrieved_workspace.key, :!=, nil)
    assert_operator(retrieved_workspace.secret_key, :!=, nil)
    assert_false(retrieved_workspace.is_test)
  end
end
