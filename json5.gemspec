# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json5/version'

Gem::Specification.new do |spec|
  spec.name          = "json5"
  spec.version       = JSON5::VERSION
  spec.authors       = ["Bartosz Kopinski"]
  spec.email         = ["bartosz.kopinski@gmail.com"]
  spec.summary       = %q{JSON5 parser in Ruby}
  spec.homepage      = "http://json5.org/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "oj"
  spec.add_development_dependency "therubyracer"
end
