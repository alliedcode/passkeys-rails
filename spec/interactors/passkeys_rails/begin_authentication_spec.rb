RSpec.describe PasskeysRails::BeginAuthentication do
  let(:call) { described_class.call }

  it "returns options from WebAuthn" do
    options = OpenStruct.new(challenge: "CHALLENGE")
    allow(WebAuthn::Credential).to receive(:options_for_get).and_return(options)

    result = call
    expect(result).to be_success
    expect(result.options).to eq options
  end
end
