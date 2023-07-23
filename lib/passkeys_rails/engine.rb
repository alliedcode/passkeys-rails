require_relative 'error_middleware'
require_relative 'controllers/helpers'
require_relative "interactors/begin_authentication"
require_relative "interactors/begin_challenge"
require_relative "interactors/begin_registration"
require_relative "interactors/finish_authentication"
require_relative "interactors/finish_registration"
require_relative "interactors/generate_auth_token"
require_relative "interactors/refresh_token"
require_relative "interactors/validate_auth_token"

module PasskeysRails
  class Engine < ::Rails::Engine
    isolate_namespace PasskeysRails

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    # Include helpers
    initializer "passkeys_rails.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        include PasskeysRails::Controllers::Helpers
      end

      ActiveSupport.on_load(:action_controller_api) do
        include PasskeysRails::Controllers::Helpers
      end
    end

    # provide a way to bail out of the render flow if needed
    initializer 'passkeys_rails.configure.middleware' do |app|
      app.middleware.use ErrorMiddleware
    end
  end
end
