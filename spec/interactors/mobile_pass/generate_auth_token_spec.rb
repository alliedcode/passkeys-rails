RSpec.describe MobilePass::GenerateAuthToken do
  let(:call) { described_class.call agent: }

  context "with an agent" do
    let(:agent) { create(:agent) }

    it "returns a properly encoded JWT" do
      result = call
      expect(result).to be_success

      token = result.auth_token
      expect(token).to be_a String

      payload, = JWT.decode(token, MobilePass.auth_token_secret, true, { algorithm: MobilePass.auth_token_algorithm })

      expect(payload['agent_id']).to eq agent.id
      expect(payload['exp']).to be_present
    end
  end
end
