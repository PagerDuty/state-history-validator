# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Daniel Ge"]
  gem.email         = ["daniel@pagerduty.com"]
  gem.summary       = "State History and State History Entry Validators"
  gem.description   = "A gem that verifies the integrity of a state history"
  gem.homepage      = "https://github.com/PagerDuty/state-history-validator"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "state_history_validator"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"
end