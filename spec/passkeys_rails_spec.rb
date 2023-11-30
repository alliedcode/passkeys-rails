RSpec.describe PasskeysRails do
  it "has a version number" do
    expect(PasskeysRails::VERSION).not_to be_nil
  end

  it "doesn't require a configuration block to have the default configuration" do
    expect(described_class.auth_token_algorithm).to eq "HS256"
  end

  context "with some valid and invalid auth tokens and requests" do
    let(:agent) { create(:agent, :registered) }
    let(:valid_token) { PasskeysRails::GenerateAuthToken.call(agent:).auth_token }
    let(:invalid_token) { "INVALID" }
    let(:valid_headers) { { 'X-Auth' => valid_token } }
    let(:invalid_headers) { { 'X-Auth' => invalid_token } }
    let(:valid_request) { instance_double(ActionDispatch::Request, headers: valid_headers) }
    let(:invalid_request) { instance_double(ActionDispatch::Request, headers: invalid_headers) }

    describe "authenticate!" do
      it "authenticates a valid token" do
        expect(described_class.authenticate!(valid_token)).to be_nil
      end

      it "authenticates a valid request" do
        expect(described_class.authenticate!(valid_request)).to be_nil
      end

      it "throws an exception on an invalid token String" do
        expect { described_class.authenticate!(invalid_token) }.to raise_error(PasskeysRails::Error, "authentication")
      end

      it "throws an exception on an invalid token Object" do
        expect { described_class.authenticate!(123) }.to raise_error(PasskeysRails::Error, "authentication")
      end

      it "throws an exception on an invalid request" do
        expect { described_class.authenticate!(invalid_request) }.to raise_error(PasskeysRails::Error, "authentication")
      end
    end

    describe "authenticate" do
      it "authenticates a valid token" do
        expect(described_class.authenticate(valid_token)).to be_success
      end

      it "authenticates a valid request" do
        expect(described_class.authenticate(valid_request)).to be_success
      end

      it "returns a context with error information on an invalid token" do
        result = described_class.authenticate(invalid_token)
        expect(result).to be_failure
        expect(result.code).to eq :token_error
      end

      it "returns a context with error information on an invalid request" do
        result = described_class.authenticate(invalid_request)
        expect(result).to be_failure
        expect(result.code).to eq :token_error
      end
    end
  end
end
