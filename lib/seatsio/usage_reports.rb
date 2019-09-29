require 'seatsio/exception'
require 'seatsio/httpClient'
require 'seatsio/domain'
require 'json'
require 'cgi'

module Seatsio
  class UsageReportsClient
    def initialize(secret_key, account_id, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, account_id, base_url)
    end

    def summary_for_all_months
      url = "reports/usage"
      body = @http_client.get(url)
      Domain::UsageSummaryForAllMoths.new(body)
    end

    def details_for_month(month)
      url = "reports/usage/month/" + month.serialize
      body = @http_client.get(url)
      body.map { |item| Domain::UsageDetails.new(item) }
    end

    def details_for_event_in_month(eventId, month)
      url = "reports/usage/month/" + month.serialize + "/event/" + eventId.to_s
      body = @http_client.get(url)
      body.map { |item| Domain::UsageForObject.new(item) }
    end
  end
end
