$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'coveralls'
Coveralls.wear!

require "seatsio"
require "minitest/autorun"
require 'custom_assertions'
require 'seatsio_test_client'

