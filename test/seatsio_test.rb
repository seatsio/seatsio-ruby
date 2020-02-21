require "json"
require "test_helper"
require 'securerandom'
require "seatsio/domain"
require "util"

class SeatsioTest < Minitest::Test

  def setup
    @user = create_test_user
    @seatsio = Seatsio::Client.new(@user["secretKey"], nil, "http://localhost:9006")
  end

  def test_that_it_has_a_version_number
    refute_nil ::Seatsio::VERSION
  end

  def test_initialize
    assert_instance_of Seatsio::Client, @seatsio
  end

  def test_initialize_charts_client
    assert_instance_of Seatsio::ChartsClient, @seatsio.charts
  end

  def test_create_and_get_chart
    chart_key = create_test_chart
    assert_kind_of(String, chart_key)

    query = @seatsio.charts.retrieve(chart_key)

    assert_kind_of(Seatsio::Domain::Chart, query)
  end

  def test_get_chart_with_events
    chart_key = create_test_chart
    chart = @seatsio.charts.retrieve_with_events(chart_key)
    assert_kind_of(Seatsio::Domain::Chart, chart)
  end

end
