require 'test_helper'
require 'util'
require 'seatsio/domain'

class UsageReportsTest < SeatsioTestClient
  def test_summary_for_all_months
    report = @seatsio.usage_reports.summary_for_all_months
  end

  def test_details_for_month
    report = @seatsio.usage_reports.details_for_month(Seatsio::Domain::Month.new(2019, 5))
  end

  def test_details_for_event_in_month
    chart = @seatsio.charts.create
    event = @seatsio.events.create(chart_key: chart.key)
    report = @seatsio.usage_reports.details_for_event_in_month(event.id, Seatsio::Domain::Month.new(2019, 6))
  end
end
