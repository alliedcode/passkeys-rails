require 'passkeys-rails'
require 'rails'

module Passkeys
  module Rails
    class Railtie < ::Rails::Railtie
      railtie_name :passkeys_rails

      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end

      generators do
        require "generators/passkeys_rails/install_generator"
      end
    end
  end
end
