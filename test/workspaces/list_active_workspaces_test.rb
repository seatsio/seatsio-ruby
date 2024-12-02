require 'test_helper'
require 'util'

class ListActiveWorkspacesTest < SeatsioTestClient
  def test_list_active_workspaces
    @seatsio.workspaces.create name: 'ws1'
    ws2 = @seatsio.workspaces.create name: 'ws2'
    @seatsio.workspaces.deactivate key: ws2.key
    @seatsio.workspaces.create name: 'ws3'

    workspaces = @seatsio.workspaces.active

    workspace_names = workspaces.collect { |workspace| workspace.name }
    assert_equal(['ws3', 'ws1', 'Production workspace'], workspace_names)
  end

  def test_filter
    @seatsio.workspaces.create name: 'someWorkspace'
    @seatsio.workspaces.create name: 'anotherWorkspace'
    @seatsio.workspaces.create name: 'anotherAnotherWorkspace'
    ws = @seatsio.workspaces.create name: 'anotherAnotherAnotherWorkspace'
    @seatsio.workspaces.deactivate key: ws.key

    workspaces = @seatsio.workspaces.active filter: 'another'

    workspace_names = workspaces.collect { |workspace| workspace.name }
    assert_equal(['anotherAnotherWorkspace', 'anotherWorkspace'], workspace_names)
  end

end
