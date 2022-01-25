require "seatsio/exception"
require "base64"
require "seatsio/httpClient"
require "seatsio/domain"
require "json"
require "cgi"

module Seatsio
  class WorkspacesClient

    def initialize(http_client)
      @http_client = http_client
    end

    def create(name:, is_test: nil)
      body = {}
      body['name'] = name
      body['isTest'] = is_test if is_test

      response = @http_client.post("workspaces", body)
      Workspace.new(response)
    end

    def update(key:, name:)
      body = {}
      body['name'] = name
      @http_client.post("workspaces/#{key}", body)
    end

    def regenerate_secret_key(key:)
      response = @http_client.post("workspaces/#{key}/actions/regenerate-secret-key")
      response['secretKey']
    end

    def activate(key:)
      @http_client.post("workspaces/#{key}/actions/activate")
    end

    def deactivate(key:)
      @http_client.post("workspaces/#{key}/actions/deactivate")
    end

    def set_default(key:)
      @http_client.post("workspaces/actions/set-default/#{key}")
    end

    def list(filter: nil)
      extended_cursor = cursor
      extended_cursor.set_query_param('filter', filter)
      extended_cursor
    end

    def active(filter: nil)
      extended_cursor = Pagination::Cursor.new(Workspace, 'workspaces/active', @http_client)
      extended_cursor.set_query_param('filter', filter)
      extended_cursor
    end

    def inactive(filter: nil)
      extended_cursor = Pagination::Cursor.new(Workspace, 'workspaces/inactive', @http_client)
      extended_cursor.set_query_param('filter', filter)
      extended_cursor
    end

    def retrieve(key:)
      response = @http_client.get("/workspaces/#{key}")
      Workspace.new(response)
    end

    private

    def cursor()
      Pagination::Cursor.new(Workspace, 'workspaces', @http_client)
    end
  end
end
