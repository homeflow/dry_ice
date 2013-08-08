require File.dirname(__FILE__) + '/../lib/httparty-icebox.rb'
require 'rspec'
require 'httparty'
require 'json'
require 'webmock/rspec'

class MockApi

  include HTTParty
  include HTTParty::Icebox
  base_uri 'example.com'


end