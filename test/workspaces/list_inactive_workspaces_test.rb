require 'test_helper'
require 'util'

class ListInactiveWorkspacesTest < SeatsioTestClient
  def test_list_inactive_workspaces
    ws1 = @seatsio.workspaces.create name: 'ws1'
    @seatsio.workspaces.deactivate key: ws1.key

    @seatsio.workspaces.create name: 'ws2'

    ws3 = @seatsio.workspaces.create name: 'ws3'
    @seatsio.workspaces.deactivate key: ws3.key

    workspaces = @seatsio.workspaces.inactive.each

    workspace_names = workspaces.collect { |workspace| workspace.name }
    assert_equal(['ws3', 'ws1'], workspace_names)
  end

  def test_filter
    @seatsio.workspaces.create name: 'someWorkspace'

    ws1 = @seatsio.workspaces.create name: 'anotherWorkspace'
    @seatsio.workspaces.deactivate key: ws1.key

    ws2 = @seatsio.workspaces.create name: 'anotherAnotherWorkspace'
    @seatsio.workspaces.deactivate key: ws2.key

    @seatsio.workspaces.create name: 'anotherAnotherAnotherWorkspace'

    cursor = @seatsio.workspaces.inactive
    cursor.set_query_param('filter', 'another')
    workspaces = cursor.each

    workspace_names = workspaces.collect { |workspace| workspace.name }
    assert_equal(['anotherAnotherWorkspace', 'anotherWorkspace'], workspace_names)
  end

end
