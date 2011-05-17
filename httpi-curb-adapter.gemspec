
lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "httpi/adapter/curb_version"

Gem::Specification.new do |s|
  s.name        = "httpi-curb-adapter"
  s.version     = HTTPI::Adapter::CURB_VERSION
  s.authors     = ["James Cook"]
  s.email       = "jcook.rubyist@gmail.com"
  s.homepage    = "http://github.com/jamescook/#{s.name}"
  s.summary     = "Curb adapter for HTTPI"
  s.description = "Curb adapter for HTTPI"

  s.rubyforge_project = s.name

  s.add_development_dependency "rspec", "~> 2.2"

  s.files = `git ls-files`.split("\n")
  s.require_path = "lib"
end
