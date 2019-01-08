# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omniauth-mediawiki/version"

Gem::Specification.new do |gem|
  gem.name        = 'omniauth-mediawiki'
  gem.version     = OmniAuth::Mediawiki::VERSION
  gem.authors     = ["Tim Waters"]
  gem.email       = 'tim@geothings.net'
  gem.homepage    = 'https://github.com/timwaters/omniauth-mediawiki'
  gem.description = %q{Mediawiki OAuth strategy for OmniAuth 1.0a }
  gem.summary     = %q{Mediawiki strategy for OmniAuth 1.0a for wikipedia.org, commons.wikimedia.org etc where the wiki has the OAuth extension installed}
  gem.license     = 'MIT'

  gem.rubyforge_project = "omniauth-mediawiki"

  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  gem.require_paths = ['lib']

  gem.add_runtime_dependency "omniauth-oauth", "~> 1.0"
  gem.add_runtime_dependency "jwt", "~> 2.0"

  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'simplecov', '~> 0.5'
  gem.add_development_dependency 'webmock', '~> 1.7'
  gem.add_development_dependency 'coveralls'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'sinatra'
end
