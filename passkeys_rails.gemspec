require_relative "lib/passkeys_rails/version"

Gem::Specification.new do |spec|
  spec.name        = "passkeys-rails"
  spec.version     = PasskeysRails::VERSION
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

  spec.add_runtime_dependency 'rails', '>= 7.2'

  spec.add_dependency "interactor", "~> 3.1.2"
  spec.add_dependency "jwt", "~> 2.9.1"
  spec.add_dependency "webauthn", "~> 3.1.0"
  # Temproarily add this to get the latest version of cbor (while we wait for webauthn to update)
  spec.add_dependency "cbor", "~> 0.5.9.8"

  spec.add_development_dependency "dotenv", "~> 3.1.4"
  spec.add_development_dependency "puma", "~> 6.4.3"
  spec.add_development_dependency "rake", "~> 13.2.1"
  spec.add_development_dependency "sprockets-rails", "~> 3.5.2"
  spec.add_development_dependency "sqlite3", "~> 2.1.0"

  spec.add_development_dependency "codecov", "~> 0.6.0"
  spec.add_development_dependency "debug", "~> 1.9.2"
  spec.add_development_dependency "simplecov", "~> 0.21.2"

  spec.add_development_dependency "reek", "~> 6.3.0"

  spec.add_development_dependency "factory_bot_rails", "~> 6.4.3"
  spec.add_development_dependency "generator_spec", "~> 0.10.0"
  spec.add_development_dependency "rspec", "~> 3.13.0"
  spec.add_development_dependency "rspec-rails", "~> 7.0.1"
  spec.add_development_dependency "timecop", "~> 0.9.10"

  spec.add_development_dependency "rubocop", "~> 1.66.1"
  spec.add_development_dependency 'rubocop-performance', "~> 1.22.1"
  spec.add_development_dependency "rubocop-rails", "~> 2.26.2"
  spec.add_development_dependency 'rubocop-rake', "~> 0.6.0"
  spec.add_development_dependency 'rubocop-rspec_rails', "~> 2.30.0"
  spec.add_development_dependency 'rubocop-factory_bot', "~> 2.26.1"

  spec.add_development_dependency 'danger-changelog', '~> 0.7.0'
  spec.add_development_dependency 'danger-toc', '~> 0.2.0'
end
