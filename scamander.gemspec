
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scamander/version"

Gem::Specification.new do |spec|
  spec.name          = "scamander"
  spec.version       = Scamander::VERSION
  spec.authors       = ["stereobooster"]
  spec.email         = ["stereobooster@gmail.com"]

  spec.summary       = "Gem to hunt memory beasts"
  spec.homepage      = "https://github.com/stereobooster/scamander"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "parser"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
