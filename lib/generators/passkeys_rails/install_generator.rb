require 'rails/generators'

module PasskeysRails
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_config
        template 'passkeys_rails_config.rb', "config/initializers/passkeys_rails.rb"
      end

      def add_routes
        route 'mount PasskeysRails::Engine => "/passkeys"'
      end

      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
