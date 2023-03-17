require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  class UsageReportsClient
    def initialize(http_client)
      @http_client = http_client
    end

    def summary_for_all_months
      url = "reports/usage"
      body = @http_client.get(url)
      UsageSummaryForAllMonths.new(body)
    end

    def details_for_month(month)
      url = "reports/usage/month/" + month.serialize
      body = @http_client.get(url)
      body.map { |item| UsageDetails.new(item) }
    end

    def details_for_event_in_month(eventId, month)
      url = "reports/usage/month/" + month.serialize + "/event/" + eventId.to_s
      body = @http_client.get(url)
      if body.empty? or !body[0].key?('usageByReason')
        body.map { |item| UsageForObjectV1.new(item) }
      else
        body.map { |item| UsageForObjectV2.new(item) }
      end
    end
  end
end
