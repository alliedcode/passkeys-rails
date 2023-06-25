require_relative "lib/mobile_pass/version"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name        = "mobile_pass"
  spec.version     = MobilePass::VERSION
  spec.authors     = ["Troy Anderson"]
  spec.email       = ["troy@alliedcode.com"]
  spec.homepage    = "https://www.alliedcode.com" # TODO: Put your gem's website or public repo URL here.
  spec.summary     = "This is a short summary" # TODO: Write a short summary, because RubyGems requires one."
  spec.description = "This is a longer description" # "TODO: Write a longer description or delete this line."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.1"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://www.alliedcode.com" # TODO: Put your gem's public repo URL here.
  spec.metadata["changelog_uri"] = "https://www.alliedcode.com" # TODO: Put your gem's CHANGELOG.md URL here.

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.5"

  spec.add_dependency "interactor", "~> 3.1.2"
  spec.add_dependency "jwt", "~> 2.7.1"
  spec.add_dependency "webauthn", "~> 3.0.0"

  spec.add_development_dependency "dotenv", "~> 2.8.1"
  spec.add_development_dependency "puma", "~> 5.6.5"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "sprockets-rails"
  spec.add_development_dependency "sqlite3", "~> 1.6.3"

  spec.add_development_dependency "codecov", "~> 0.2.12"
  spec.add_development_dependency "debug", "~> 1.8.0"
  spec.add_development_dependency "simplecov", "~> 0.22.0"

  spec.add_development_dependency "reek", "~> 6.1.4"

  spec.add_development_dependency "factory_bot_rails", "~> 6.2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0.3"
  spec.add_development_dependency "timecop", "~> 0.9.6"
  spec.add_development_dependency "generator_spec", "~> 0.9.4"

  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency 'rubocop-performance', "~> 1.18.0"
  spec.add_development_dependency "rubocop-rails", "~> 2.20.2"
  spec.add_development_dependency 'rubocop-rspec', "~> 2.22.0"
end
# rubocop:enable Metrics/BlockLength
