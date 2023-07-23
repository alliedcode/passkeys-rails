require_relative "lib/passkeys/rails/version"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name        = "passkeys-rails"
  spec.version     = Passkeys::Rails::VERSION
  spec.authors     = ["Troy Anderson"]
  spec.email       = ["troy@alliedcode.com"]
  spec.homepage    = "https://github.com/alliedcode/passkeys-rails"
  spec.summary     = "PassKey authentication back end with simple API"
  spec.description = "Devise is awesome, but we don't need all that UI/UX for PassKeys. This gem is to make it easy to provide a back end that authenticates a mobile front end with PassKeys."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alliedcode/passkeys-rails"
  spec.metadata["changelog_uri"] = "https://github.com/alliedcode/passkeys-rails/CHANGELOG.md"

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "CHANGELOG.md", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_runtime_dependency 'rails', '~> 7.0', '>= 7.0.5'

  spec.add_dependency "interactor", "~> 3.1.2"
  spec.add_dependency "jwt", "~> 2.7.1"
  spec.add_dependency "webauthn", "~> 3.0.0"

  spec.add_development_dependency "dotenv", "~> 2.8.1"
  spec.add_development_dependency "puma", "~> 5.6.5"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "sprockets-rails", "~> 3.4.2"
  spec.add_development_dependency "sqlite3", "~> 1.6.3"

  spec.add_development_dependency "codecov", "~> 0.2.12"
  spec.add_development_dependency "debug", "~> 1.8.0"
  spec.add_development_dependency "simplecov", "~> 0.22.0"

  spec.add_development_dependency "reek", "~> 6.1.4"

  spec.add_development_dependency "factory_bot_rails", "~> 6.2.0"
  spec.add_development_dependency "generator_spec", "~> 0.9.4"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0.3"
  spec.add_development_dependency "timecop", "~> 0.9.6"

  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency 'rubocop-performance', "~> 1.18.0"
  spec.add_development_dependency "rubocop-rails", "~> 2.20.2"
  spec.add_development_dependency 'rubocop-rake', "~> 0.6.0"
  spec.add_development_dependency 'rubocop-rspec', "~> 2.22.0"
end
# rubocop:enable Metrics/BlockLength
