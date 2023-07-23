require "rails"
require "active_support/core_ext/numeric/time"
require "active_support/dependencies"

require "interactor"
require "jwt"
require "webauthn"

module Passkeys::Rails
  class Engine < ::Rails::Engine
    isolate_namespace Passkeys::Rails

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end
