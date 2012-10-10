# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "graphability/version"

Gem::Specification.new do |s|
  s.name        = "graphability"
  s.version     = Graphability::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Return graph objects from url content"
  s.homepage    = "http://github.com/fonzo14/graphability"
  s.authors     = ['Thomas Mahier']
  s.email       = 'thomas_mahier@yahoo.fr'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.require_paths = ["lib"]

  s.extra_rdoc_files  = [ "README.md", "MIT-LICENSE" ]
  s.rdoc_options      = [ "--charset=UTF-8" ]

  s.required_rubygems_version = ">= 1.3.6"

  # = Library dependencies
  #
  s.add_dependency "nokogiri"
  s.add_dependency "postrank-uri", "~> 1.0.17"

  # = Development dependencies
  #
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rb-inotify"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "em-http-request", "~> 1.0.2"
  s.add_development_dependency "em-synchrony", "~> 1.0.2"

  s.description = <<-DESC
   
  DESC
end