# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "e9_rails/version"

Gem::Specification.new do |s|
  s.name        = "e9_rails"
  s.version     = E9Rails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Travis Cox"]
  s.email       = ["travis@e9digital.com"]
  s.homepage    = "http://www.e9digital.com"
  s.summary     = %q{A collection of helpers and extensions used in e9 Rails 3 projects}
  s.description = %q{}

  s.rubyforge_project = "e9_rails"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 3.0.0"
  s.add_dependency "inherited_resources"
end
