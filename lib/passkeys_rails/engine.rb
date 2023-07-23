require_relative 'error_middleware'
require_relative 'controllers/helpers'

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
    initializer "passkeys_rails.url_helpers" do
      ActiveSupport.on_load(:action_controller) do
        include PasskeysRails::Controllers::Helpers
      end
    end

    # provide a way to bail out of the render flow if needed
    initializer 'passkeys_rails.configure.middleware' do |app|
      app.middleware.use ErrorMiddleware
    end
  end
end
