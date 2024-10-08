RSpec.describe PasskeysRails::PasskeysController do
  let(:call_api) { post '/passkeys_rails/debug_register', params:, headers: }

  context "when debug_login_regex is empty" do
    before { allow(PasskeysRails).to receive(:debug_login_regex).and_return(nil) }

    let(:params) { {} }
    let(:headers) { {} }

    it 'responds that there are no matching routes' do
      expect(call_api).to eq 404
    end
  end

  context "when debug_login_regex has a regex that matches adam-123" do
    before { allow(PasskeysRails).to receive(:debug_login_regex).and_return(/^adam-\d+$/) }

    include_context 'with api params'

    it_behaves_like 'an api that requires some params'

    context 'with required params' do
      let(:required_params) { { username: 'adam-123' } }

      context 'with valid parameters and a successfull call to DebugRegister' do
        before {
          allow(PasskeysRails::DebugRegister)
            .to receive(:call!)
            .and_return(Interactor::Context.build(username: "adam-123", auth_token: "456", agent: create(:agent)))
        }

        it 'Succeeds and returns instance credentails' do
          call_api

          expect_success
          expect(PasskeysRails::DebugRegister).to have_received(:call!).exactly(1).time
          expect(json.keys).to match_array %w[username auth_token]
          expect(json).to include(username: "adam-123", auth_token: "456")
        end

        it_behaves_like "a notifier", :did_register
      end
    end
  end
end
