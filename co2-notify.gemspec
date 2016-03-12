# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'co2-notify/version'

Gem::Specification.new do |spec|
  spec.name          = "co2-notify"
  spec.version       = Co2Notify::VERSION
  spec.authors       = ["Arkadiy Butermanov"]
  spec.email         = ["arkadiy.butermanov@flatstack.com"]

  spec.summary       = %q{Hipchat CO2 level notifier}
  spec.homepage      = "https://github.com/arkadiybutermanov/co2mon-notifier"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   << "co2-notify"
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "hipchat"
  spec.add_dependency "activesupport"
  spec.add_dependency "co2mon"
end
