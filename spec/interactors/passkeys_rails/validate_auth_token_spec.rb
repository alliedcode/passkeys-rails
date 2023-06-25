RSpec.describe PasskeysRails::ValidateAuthToken do
  let(:call) { described_class.call auth_token: }

  context "with a valid auth_token" do
    let(:agent) { create(:agent) }
    let(:auth_token) { PasskeysRails::GenerateAuthToken.call(agent:).auth_token }

    it "returns the agent" do
      result = call
      expect(result).to be_success
      expect(result.agent).to eq agent
    end
  end

  context "with an bogus auth_token" do
    let(:auth_token) { "BOGUS" }

    it "returns an appropriate error" do
      result = call
      expect(result).to be_failure
      expect(result.code).to eq :token_error
      expect(result.message).to eq "Not enough or too many segments"
    end
  end

  context "with a JWT with an agent_id, but without an expiration" do
    let(:auth_token) { JWT.encode({ agent_id: 123 }, PasskeysRails.auth_token_secret, PasskeysRails.auth_token_algorithm) }

    it "returns an appropriate error" do
      result = call
      expect(result).to be_failure
      expect(result.code).to eq :token_error
      expect(result.message).to eq "Missing required claim exp"
    end
  end

  context "with a JWT with an expiration, but without an agent_id" do
    let(:auth_token) { JWT.encode({ exp: 1.day.from_now.to_i }, PasskeysRails.auth_token_secret, PasskeysRails.auth_token_algorithm) }

    it "returns an appropriate error" do
      result = call
      expect(result).to be_failure
      expect(result.code).to eq :token_error
      expect(result.message).to eq "Missing required claim agent_id"
    end
  end

  context "with a JWT with an expiration, but an agent_id that doesn't exist" do
    let(:auth_token) { JWT.encode({ exp: 1.day.from_now.to_i, agent_id: 0 }, PasskeysRails.auth_token_secret, PasskeysRails.auth_token_algorithm) }

    it "returns an appropriate error" do
      result = call
      expect(result).to be_failure
      expect(result.code).to eq :invalid_token
      expect(result.message).to eq "Invalid token - no agent exists with agent_id"
    end
  end
end
