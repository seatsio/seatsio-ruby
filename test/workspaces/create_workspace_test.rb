require 'test_helper'
require 'util'
require 'seatsio/domain'

class CreateWorkspaceTest < SeatsioTestClient

  def test_create_workspace
    workspace = @seatsio.workspaces.create name: 'my workspace'

    assert_operator(workspace.id, :!=, 0)
    assert_equal('my workspace', workspace.name)
    assert_operator(workspace.key, :!=, nil)
    assert_operator(workspace.secret_key, :!=, nil)
    assert_false(workspace.is_test)
  end

  def test_create_test_workspace
    workspace = @seatsio.workspaces.create name: 'my workspace', is_test: true

    assert_operator(workspace.id, :!=, 0)
    assert_equal('my workspace', workspace.name)
    assert_operator(workspace.key, :!=, nil)
    assert_operator(workspace.secret_key, :!=, nil)
    assert_true(workspace.is_test)
  end
end
