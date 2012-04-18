# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "browserid-provider/version"

Gem::Specification.new do |s|
  s.name        = "browserid-provider"
  s.version     = BrowserID::Provider::VERSION
  s.authors     = ["ringe"]
  s.email       = ["runar@rin.no"]
  s.homepage    = "https://github.com/ringe/browserid-provider"
  s.summary     = %q{Rack-based Mozilla BrowserID Provider}
  s.description = %q{With the BrowserID provider you enable your users to authenticate themselves across the web using a single authority.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
