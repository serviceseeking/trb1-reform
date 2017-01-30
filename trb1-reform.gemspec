lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trb1-reform/version'

Gem::Specification.new do |spec|
  spec.name          = "trb1-reform"
  spec.version       = Trb1::Reform::VERSION
  spec.authors       = ["Nick Sutterer", "Garrett Heinlen"]
  spec.email         = ["apotonick@gmail.com", "heinleng@gmail.com"]
  spec.description   = %q{Form object decoupled from models.}
  spec.summary       = %q{Form object decoupled from models with validation, population and presentation.}
  spec.homepage      = "https://github.com/apotonick/reform"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency             "trb1-disposable",     ">= 0.3.0", "< 0.4.0"
  spec.add_dependency             "trb1-uber",      "~> 0.0.11"
  spec.add_dependency             "representable",  ">= 2.4.0", "< 3.1.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "dry-types"
  spec.add_development_dependency "multi_json"
  spec.add_development_dependency "dry-validation", ">= 0.7.0"
end
