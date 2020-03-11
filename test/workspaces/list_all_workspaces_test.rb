require 'test_helper'
require 'util'

class ListAllWorkspacesTest < SeatsioTestClient
  def test_list_all_workspaces
    @seatsio.workspaces.create name: 'ws1'
    @seatsio.workspaces.create name: 'ws2'
    @seatsio.workspaces.create name: 'ws3'

    workspaces = @seatsio.workspaces.list

    workspace_names = workspaces.collect { |workspace| workspace.name }
    assert_equal(['ws3', 'ws2', 'ws1', 'Default workspace'], workspace_names)
  end

  def test_filter
    @seatsio.workspaces.create name: 'someWorkspace'
    @seatsio.workspaces.create name: 'anotherWorkspace'
    @seatsio.workspaces.create name: 'anotherAnotherWorkspace'

    workspaces = @seatsio.workspaces.list filter: 'another'

    workspace_names = workspaces.collect { |workspace| workspace.name }
    assert_equal(['anotherAnotherWorkspace', 'anotherWorkspace'], workspace_names)
  end

end
