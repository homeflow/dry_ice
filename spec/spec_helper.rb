require File.dirname(__FILE__) + '/../lib/dry_ice.rb'
require 'rspec'
require 'httparty'
require 'json'
require 'webmock/rspec'

class MockApi

  include HTTParty
  include HTTParty::DryIce
  base_uri 'example.com'


end