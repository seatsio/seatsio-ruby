require 'seatsio/version'
require 'seatsio/charts'
require 'seatsio/subaccounts'
require 'seatsio/workspaces'
require 'seatsio/events'
require 'seatsio/hold_tokens'
require 'seatsio/chart_reports'
require 'seatsio/event_reports'
require 'seatsio/usage_reports'

module Seatsio
  class Client
    attr_reader :charts, :subaccounts, :workspaces, :events,
                :hold_tokens, :chart_reports, :event_reports, :usage_reports

    def initialize(region, secret_key, workspace_key = nil)
      base_url = region.url
      @http_client = Seatsio::HttpClient.new(secret_key, workspace_key, base_url)
      @charts = ChartsClient.new(@http_client)
      @subaccounts = SubaccountsClient.new(@http_client)
      @workspaces = WorkspacesClient.new(@http_client)
      @events = EventsClient.new(@http_client)
      @hold_tokens = HoldTokensClient.new(@http_client)
      @chart_reports = ChartReportsClient.new(@http_client)
      @event_reports = EventReportsClient.new(@http_client)
      @usage_reports = UsageReportsClient.new(@http_client)
    end

    def max_retries(max_retries)
      @http_client.max_retries=(max_retries)
      self
    end
  end


  class Region
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def self.EU()
      return Region.new(Region.url_for_id("eu"))
    end

    def self.NA()
      return Region.new(Region.url_for_id("na"))
    end

    def self.SA()
      return Region.new(Region.url_for_id("sa"))
    end

    def self.OC()
      return Region.new(Region.url_for_id("oc"))
    end

    def self.url_for_id(id)
      return "https://api-" + id + ".seatsio.net"
    end
  end
end
