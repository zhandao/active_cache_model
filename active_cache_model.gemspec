
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_cache_model/version"

Gem::Specification.new do |spec|
  spec.name          = "active_cache_model"
  spec.version       = ActiveCacheModel::VERSION
  spec.authors       = ["zhandao"]
  spec.email         = ["x@skippingcat.com"]

  spec.summary       = 'Simple encapsulation for using Rails.cache like ActiveRecord'
  spec.description   = 'Simple encapsulation for using Rails.cache like ActiveRecord'
  spec.homepage      = "https://skippingcat.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency 'activemodel'
  spec.add_dependency 'multi_json'
end
