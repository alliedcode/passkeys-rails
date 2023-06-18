require 'rails/generators'

module MobilePass
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      desc 'Creates a MobilePass config file.'

      def copy_config
        template 'mobile_pass_config.rb', Rails.root.join("config/mobile_pass.rb")
      end
    end
  end
end
