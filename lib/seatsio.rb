require 'seatsio/version'
require 'seatsio/charts'
require 'seatsio/accounts'
require 'seatsio/subaccounts'
require 'seatsio/workspaces'
require 'seatsio/events'
require 'seatsio/hold_tokens'
require 'seatsio/chart_reports'
require 'seatsio/event_reports'
require 'seatsio/usage_reports'

module Seatsio
  # Main Seatsio Class
  class Client
    attr_reader :charts, :accounts, :subaccounts, :workspaces, :events,
                :hold_tokens, :chart_reports, :event_reports, :usage_reports

    def initialize(secret_key, workspace_key = nil, base_url = 'https://api.seatsio.net')
      @charts = ChartsClient.new(secret_key, workspace_key, base_url)
      @accounts = AccountsClient.new(secret_key, workspace_key, base_url)
      @subaccounts = SubaccountsClient.new(secret_key, workspace_key, base_url)
      @workspaces = WorkspacesClient.new(secret_key, base_url)
      @events = EventsClient.new(secret_key, workspace_key, base_url)
      @hold_tokens = HoldTokensClient.new(secret_key, workspace_key, base_url)
      @chart_reports = ChartReportsClient.new(secret_key, workspace_key, base_url)
      @event_reports = EventReportsClient.new(secret_key, workspace_key, base_url)
      @usage_reports = UsageReportsClient.new(secret_key, workspace_key, base_url)
    end
  end
end
