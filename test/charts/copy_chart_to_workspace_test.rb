require  "test_helper"
require "util"

class CopyChartToWorkspaceTest < SeatsioTestClient
  def test_copy_to_workspace
    chart = @seatsio.charts.create name: 'my chart', venue_type: 'BOOTHS'
    workspace = @seatsio.workspaces.create name: 'my ws'

    copied_chart = @seatsio.charts.copy_to_workspace(chart.key, workspace.key)

    workspace_client = test_client(workspace.secret_key, nil)
    assert_equal("my chart", copied_chart.name)

    retrieved_chart = workspace_client.charts.retrieve(copied_chart.key)
    assert_equal("my chart", retrieved_chart.name)

    drawing = workspace_client.charts.retrieve_published_version(copied_chart.key)
    assert_equal("BOOTHS", drawing.venue_type)

  end

end
