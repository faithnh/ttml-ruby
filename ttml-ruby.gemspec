# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ttml/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Juergen Fesslmeier"]
  gem.email         = ["jfesslmeier@gmail.com"]
  gem.description   = %q{Parse a TTML file}
  gem.summary       = %q{Minimal parsing for timed text markup language (http://www.w3.org/TR/ttaf1-dfxp/)}
  gem.homepage      = "http://github.com/chinshr/ttml-ruby"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ttml-ruby"
  gem.require_paths = ["lib"]
  gem.version       = TTML::VERSION

  gem.add_runtime_dependency "nokogiri"
  gem.add_runtime_dependency "optimist", "~> 3.0.1"
end
