require 'test_helper'
require 'util'

class DeleteWorkspaceTest < SeatsioTestClient
  def test_delete_inactive_workspace
    workspace = @seatsio.workspaces.create name: 'a ws'
    @seatsio.workspaces.deactivate key: workspace.key

    @seatsio.workspaces.delete key: workspace.key

    assert_raises(Seatsio::Exception::NotFoundException) do
      @seatsio.workspaces.retrieve key: workspace.key
    end
  end

  def test_delete_active_workspace
    workspace = @seatsio.workspaces.create name: 'a ws'

    assert_raises(Seatsio::Exception::SeatsioException) do
      @seatsio.workspaces.delete key: workspace.key
    end
  end
end
