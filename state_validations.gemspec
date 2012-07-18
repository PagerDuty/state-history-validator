# -*- encoding: utf-8 -*-

# Note to self: the module file in lib/ needs to have the same name as this file
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Daniel Ge", "PagerDuty, Inc."]
  gem.email         = ["daniel@pagerduty.com"]
  gem.summary       = "State History and State History Entry Validators"
  gem.description   = "A gem that verifies the integrity of a state history"
  gem.homepage      = "https://github.com/PagerDuty/state-history-validator"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "state_validations"
  gem.require_paths = ["lib"]
  gem.version       = "0.2.0"

  # Dependencies
  gem.add_runtime_dependency "activemodel", ">= 3.0.0"
  gem.add_runtime_dependency "activesupport", ">= 3.0.0"

  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit", "= 2.2"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "shoulda"
end
