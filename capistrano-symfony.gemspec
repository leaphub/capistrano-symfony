# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-symfony'
  spec.version       = '0.5.0'
  spec.authors       = ['Thomas Tourlourat', 'Boris Guéry', 'Christoph Foehrdes']
  spec.email         = ['thomas@tourlourat.com', 'guery.b@gmail.com', 'cfoehrdes@leaphub.de']
  spec.description   = %q{Symfony support for Capistrano 3.x}
  spec.summary       = %q{Welcome to easy Symfony deployment}
  spec.homepage      = 'https://github.com/leaphub/capistrano-symfony/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'capistrano', '~> 3.1'
  spec.add_runtime_dependency 'capistrano-composer', '~> 0.0.4'
  spec.add_runtime_dependency 'capistrano-file-permissions', '~> 0.1.0'

  spec.add_development_dependency 'rake', '~> 10.0'
end
