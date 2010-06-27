# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'contacts/version'

Gem::Specification.new do |s|
  s.name        = 'patch-contacts'
  s.date        = Date.today.strftime('%Y-%m-%d')
  s.version     = Contacts::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mislav Marohnić", "George Ogata"]
  s.email       = ["george.ogata@gmail.com"]
  s.homepage    = "http://github.com/oggy/contacts/tree/patch"
  s.summary     = "Import users' contacts lists from Google, Yahoo!, and Windows Live."
  s.description = ''

  s.add_dependency 'oauth', '~> 0.4.0'
  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "rspec"

  s.files = Dir["{lib,rails,spec,vendor}/**/*", "LICENSE", "README.*", "Rakefile"]
  s.test_files = Dir["spec/**/*"]
  s.extra_rdoc_files = ["LICENSE", "README.markdown"]
  s.require_path = 'lib'
  s.specification_version = 3
  s.rdoc_options = ["--charset=UTF-8"]
end
