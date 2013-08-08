# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dry_ice/version"

Gem::Specification.new do |s|
  s.name        = "homeflow-httparty-icebox"
  s.version     = Httparty::DryIce::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Cooper"]
  s.email       = ["daniel@14lines.com"]
  s.homepage    = "https://github.com/homeflow/dryice"
  s.summary     = %q{Caching for HTTParty}
  s.description = %q{Cache responses in HTTParty models}

  s.add_dependency("httparty", "~> 0.9.0")
  s.add_dependency("msgpack")

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end
