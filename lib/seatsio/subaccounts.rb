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

    def update(id:, name: nil, email: nil)
      body = {}
      body['name'] = name if name
      body['email'] = email if email
      @http_client.post("subaccounts/#{id}", body)
    end

    def list
      cursor
    end

    def active
      cursor status: 'active'
    end

    def inactive
      cursor status: 'inactive'
    end

    def activate(id:)
      @http_client.post("/subaccounts/#{id}/actions/activate")
    end

    def deactivate(id:)
      @http_client.post("/subaccounts/#{id}/actions/deactivate")
    end

    def retrieve(id:)
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

    def regenerate_designer_key(id:)
      @http_client.post("/subaccounts/#{id}/designer-key/actions/regenerate")
    end

    private

    def do_create(name: nil, email: nil)
      body = {}
      body['name'] = name if name
      body['email'] = email if email
      response = @http_client.post('subaccounts', body)
      Domain::Subaccount.new(response)
    end

    def cursor(status: nil)
      endpoint = status ? "subaccounts/#{status}" : 'subaccounts'
      Pagination::Cursor.new(Domain::Subaccount, endpoint, @http_client)
    end
  end
end
