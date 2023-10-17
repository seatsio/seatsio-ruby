require 'test_helper'
require 'util'
require 'seatsio/domain'
require 'seatsio/exception'

class UsageReportsTest < SeatsioTestClient
  def test_usage_report_for_all_months
    assert_demo_company_secret_key_set
    client = test_client(demo_company_secret_key, nil)

    report = client.usage_reports.summary_for_all_months

    assert_not_nil(report.usage_cutoff_date)
    assert_true(report.usage.length > 0)
    assert_equal(2014, report.usage[0].month.year)
    assert_equal(2, report.usage[0].month.month)
  end

  def test_usage_report_month
    assert_demo_company_secret_key_set
    client = test_client(demo_company_secret_key, nil)

    report = client.usage_reports.details_for_month(Seatsio::Month.new(2021, 11))

    assert_true(report.length > 0)
    assert_true(report[0].usage_by_chart.length > 0)
    assert_equal(143, report[0].usage_by_chart[0].usage_by_event[0].num_used_objects)
  end

  def test_usage_report_event_in_month
    assert_demo_company_secret_key_set
    client = test_client(demo_company_secret_key, nil)

    report = client.usage_reports.details_for_event_in_month(580293, Seatsio::Month.new(2021, 11))

    assert_true(report.length > 0)
    assert_equal(1, report[0].num_first_selections)
  end
end
