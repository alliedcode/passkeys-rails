require 'generators/mobile_pass/install_generator'

# rubocop:disable RSpec/FilePath
RSpec.describe MobilePass::Generators::InstallGenerator do
  before { remove_config }

  after { remove_config }

  it 'installs config file properly' do
    described_class.start
    expect(File.file?(config_file)).to be true
  end
  # rubocop:enable RSpec/FilePath
end
