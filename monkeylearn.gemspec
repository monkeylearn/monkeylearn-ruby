# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = 'monkeylearn'
  spec.summary = 'Ruby client for the MonkeyLearn API'
  spec.description = 'A simple client for the MonkeyLearn API'
  spec.authors = ['Monkeylearn']
  spec.email = ['hello@monkeylearn.com']
  spec.homepage = 'https://github.com/monkeylearn/monkeylearn-ruby'

  spec.version = '3.2.0'

  spec.add_dependency 'faraday', '>= 0.9.2', '<= 0.15.0'

  spec.licenses = ['MIT']

  spec.files = %w(README.md monkeylearn.gemspec)
  spec.files += Dir.glob('lib/**/*.rb')
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.2'
  spec.required_rubygems_version = '>= 1.3.5'
end
