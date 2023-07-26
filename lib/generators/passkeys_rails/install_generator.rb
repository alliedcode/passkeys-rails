require 'rails/generators'

module PasskeysRails
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc "Adds passkeys config file to your application."
      def copy_config
        template 'passkeys_rails_config.rb', "config/initializers/passkeys_rails.rb"
      end

      desc "Adds passkeys routes to your application."
      def add_routes
        route 'mount PasskeysRails::Engine => "/passkeys"'
      end

      desc "Copies migrations to your application."
      def copy_migrations
        rake("passkeys_rails:install:migrations")
      end

      desc "Displays readme during installation."
      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
