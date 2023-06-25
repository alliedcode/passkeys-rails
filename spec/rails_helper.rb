# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

# Use the dummy app for testing this gem
require_relative '../spec/dummy/config/environment'
ENV['RAILS_ROOT'] ||= "#{File.dirname(__FILE__)}../../../spec/dummy"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
require "mobile_pass"
require 'factory_bot_rails'
require 'debug'
require 'timecop'
require 'generator_spec'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec::Matchers.define_negated_matcher :not_change, :change
RSpec::Matchers.define_negated_matcher :not_have_enqueued_job, :have_enqueued_job

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.mock_with :rspec
  config.order = "random"

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Include our helpers
  config.include Requests::JsonHelpers
  config.include Requests::APIHelpers
  config.include Requests::WebauthnHelpers

  # infer FactoryBot as the base of :create & :build calls
  config.include FactoryBot::Syntax::Methods
end
