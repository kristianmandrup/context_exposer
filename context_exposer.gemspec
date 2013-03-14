# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'context_exposer/version'

Gem::Specification.new do |spec|
  spec.name          = "context_exposer"
  spec.version       = ContextExposer::VERSION
  spec.authors       = ["Kristian Mandrup"]
  spec.email         = ["kmandrup@gmail.com"]
  spec.description   = %q{Exposes a ViewContext object to the View with all the data needed by the view}
  spec.summary       = %q{The Context object becomes the single communication point between View and Controller}
  spec.homepage      = "https://github.com/kristianmandrup/context_exposer"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
