require "rails"
require "active_support/core_ext/numeric/time"
require "active_support/dependencies"

require "interactor"
require "jwt"
require "webauthn"

require_relative 'controllers/helpers'
require_relative "interactors/begin_authentication"
require_relative "interactors/begin_challenge"
require_relative "interactors/begin_registration"
require_relative "interactors/finish_authentication"
require_relative "interactors/finish_registration"
require_relative "interactors/generate_auth_token"
require_relative "interactors/refresh_token"
require_relative "interactors/validate_auth_token"

module Passkeys
  module Rails
    class Engine < ::Rails::Engine
      isolate_namespace Passkeys::Rails

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot
        g.factory_bot dir: 'spec/factories'
        g.assets false
        g.helper false
      end

      # Include helpers
      initializer "passkeys-rails.helpers" do
        ActiveSupport.on_load(:action_controller_base) do
          include Passkeys::Rails::Controllers::Helpers
        end

        ActiveSupport.on_load(:action_controller_api) do
          include Passkeys::Rails::Controllers::Helpers
        end
      end
    end
  end
end
