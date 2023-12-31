require 'generators/passkeys_rails/install_generator'

RSpec.describe PasskeysRails::Generators::InstallGenerator do
  destination Rails.root.join('tmp')

  def create_temporary_routes_file
    FileUtils.mkdir_p(File.join(destination_root, "config"))

    routes_content = <<~CONTENT
      Rails.application.routes.draw do
        root to: 'application#index'
      end
    CONTENT

    File.write(File.join(destination_root, "config/routes.rb"), routes_content)
  end

  before do
    prepare_destination
    create_temporary_routes_file
    run_generator
  end

  it "has the correct structure and contents" do
    expect(destination_root).to have_structure {
      directory "config" do
        directory "initializers" do
          file "passkeys_rails.rb" do
            contains 'PasskeysRails.config do |c|'
          end
        end
        file 'routes.rb' do
          contains 'mount PasskeysRails::Engine => "/passkeys"'
        end
      end
    }
  end
end
