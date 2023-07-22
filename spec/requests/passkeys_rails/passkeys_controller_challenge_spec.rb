RSpec.describe PasskeysRails::PasskeysController do
  let(:call_api) { post '/passkeys_rails/passkeys/challenge', params:, headers: }

  include_context 'with api params'

  context 'with no params' do
    it 'begins the login process and returns the passkey challenge fields' do
      call_api
      expect_success
      expect(json.keys).to match(%w[challenge timeout extensions allowCredentials])
    end
  end

  context 'with the username param' do
    let(:optional_params) { { username: } }
    let(:username) { '' }

    context 'when the username is not yet taken' do
      let(:username) { 'Testing 1 2 3' }

      it 'begins the registration process and returns the passkey challenge fields' do
        call_api
        expect_success
        expect(json.keys).to match(%w[challenge timeout extensions rp user pubKeyCredParams])
      end
    end

    context 'when the username is already taken' do
      let!(:existing_agent) { create(:agent) }
      let(:username) { existing_agent.username }

      it 'fails with an appropriate error' do
        call_api
        expect(error).to match([:authentication, 'validation_errors', "Username has already been taken"])
      end
    end
  end
end
