require 'generators/mobile_pass/install_generator'

RSpec.describe MobilePass::Generators::InstallGenerator do
  before { remove_config }

  after { remove_config }

  it 'installs config file properly' do
    described_class.start
    expect(File.file?(config_file)).to be true
  end
end
