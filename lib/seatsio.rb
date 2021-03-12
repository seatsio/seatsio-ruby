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
      @charts = ChartsClient.new(secret_key, workspace_key, base_url)
      @subaccounts = SubaccountsClient.new(secret_key, workspace_key, base_url)
      @workspaces = WorkspacesClient.new(secret_key, base_url)
      @events = EventsClient.new(secret_key, workspace_key, base_url)
      @hold_tokens = HoldTokensClient.new(secret_key, workspace_key, base_url)
      @chart_reports = ChartReportsClient.new(secret_key, workspace_key, base_url)
      @event_reports = EventReportsClient.new(secret_key, workspace_key, base_url)
      @usage_reports = UsageReportsClient.new(secret_key, workspace_key, base_url)
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
