require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"
require "seatsio/domain"

module Seatsio
  class SubaccountsClient
    def initialize(secret_key, base_url)
      @http_client = ::Seatsio::HttpClient.new(secret_key, base_url)
    end

    def create(name: nil, email: nil)
      body = {}
      body['name'] = name if name
      body['email'] = email if email

      response = @http_client.post("subaccounts", body)
      Domain::Subaccount.new(response)
    end

    def activate(id: nil)
      @http_client.post("/subaccounts/#{id}/actions/activate")
    end

    def deactivate(id: nil)
      @http_client.post("/subaccounts/#{id}/actions/deactivate")
    end

    def retrieve(id: nil)
      response = @http_client.get("/subaccounts/#{id}")
      Domain::Subaccount.new(response)
    end

    def copy_chart_to_parent(id: nil, chart_key: nil)
      response = @http_client.post("/subaccounts/#{id}/charts/#{chart_key}/actions/copy-to/parent")
      Domain::Chart.new(response)
    end

    def copy_chart_to_subaccount(from_id: nil, to_id: nil, chart_key: nil)
      response = @http_client.post("/subaccounts/#{from_id}/charts/#{chart_key}/actions/copy-to/#{to_id}")
      Domain::Chart.new(response)
    end

    def create_with_email(email: nil, name: nil)
      do_create name: name, email: email
    end

    private

    def do_create(name: nil, email: nil)
      body = {}
      body['name'] = name if name
      body['email'] = email if email
      response = @http_client.post('subaccounts', body)
      Domain::Subaccount.new(response)
    end
  end
end
