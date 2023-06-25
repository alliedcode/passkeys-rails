require 'rails/generators'

module MobilePass
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_config
        template 'mobile_pass_config.rb', "config/initializers/mobile_pass.rb"
      end

      def add_routes
        route 'mount MobilePass::Engine => "/mobile_pass"'
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
