require 'test_helper'
require 'util'

class ListAllWorkspacesTest < SeatsioTestClient
  def test_list_all_workspaces
    @seatsio.workspaces.create name: 'ws1'
    @seatsio.workspaces.create name: 'ws2'
    @seatsio.workspaces.create name: 'ws3'

    workspaces = @seatsio.workspaces.list

    workspace_names = workspaces.collect {|workspace| workspace.name}
    assert_equal(['ws3', 'ws2', 'ws1', 'Main workspace'], workspace_names)
  end

end
