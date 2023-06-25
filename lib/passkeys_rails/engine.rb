require_relative 'error_middleware'
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

    config.to_prepare do
      # include our helper methods in the host application's ApplicationController
      ::ApplicationController.include ApplicationHelper
    end

    # provide a way to bail out of the render flow if needed
    initializer 'passkeys_rails.configure.middleware' do |app|
      app.middleware.use ErrorMiddleware
    end
  end
end
