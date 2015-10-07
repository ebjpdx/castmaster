# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'castmaster/version'


Gem::Specification.new do |s|
  s.name = 'castmaster'
  s.version = Castmaster::VERSION
  s.date = '2014-02-13'
  s.summary = 'A taskmaster for your forecasts'
  s.description = <<-DESC
    A tool to manage forecast runs (i.e. a taskmaster for forecasts). Castmaster provides a framework for defining procedures that 
    generate forecasts, understands dependencies on other forecasts, forecast parameters, and updated input data.  
    DESC
  s.authors = ["Eric B. Johnson"]
  s.email = 'ebj.pdx@gmail.com'
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  # s.homepage = ''
  s.license = 'MIT'

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.add_runtime_dependency 'activerecord', '>= 3.2'
  s.add_runtime_dependency 'activesupport', '>= 3.2.13'
  s.add_runtime_dependency 'json', '>= 1.5.5'
  s.add_runtime_dependency 'require_all', '>= 1.2.1'
  s.add_runtime_dependency 'popen4', '>= 0.1.2'

end