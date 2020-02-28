$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require 'webmock/minitest'
require "seatsio"
require "minitest/autorun"
require 'custom_assertions'
require 'seatsio_test_client'

WebMock.allow_net_connect!

