# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sybase/version"

Gem::Specification.new do |s|
  s.name        = "ffi-sybase"
  s.version     = Sybase::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jari Bakken"]
  s.email       = ["jari.bakken@gmail.com"]
  s.homepage    = "http://github.com/jarib/ffi-sybase"
  s.summary     = %q{Ruby/FFI bindings for Sybase OCS}
  s.description = %q{Ruby/FFI bindings for Sybase's Open Client library.}

  s.rubyforge_project = "ffi-sybase"

  s.add_dependency "ffi", ">= 0.6.3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
