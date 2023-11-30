RSpec.describe PasskeysRails::PasskeysController do
  let(:call_api) { post '/passkeys_rails/register', params:, headers: }

  include_context 'with api params'

  it_behaves_like 'an api that requires some params'

  shared_examples "a successful registration" do
    it 'Succeeds and returns instance credentails' do
      call_api
      expect_success
      expect(PasskeysRails::FinishRegistration).to have_received(:call!).exactly(1).time
      expect(json.keys).to match_array %w[username auth_token]
      expect(json).to include(username: "name", auth_token: "123")
    end
  end

  context 'with required params' do
    let(:required_params) { { credential: } }
    let(:credential) { { id: '123', rawId: '123', type: 'hmm', response: auth_response } }
    let(:auth_response) { { attestationObject: '123', clientDataJSON: '{}' } }

    context 'with valid parameters and a successfull call to FinishLogin' do
      let(:agent) { create(:agent) }
      let(:interactor_context) { { credential:, authenticatable_info:, username: nil, challenge: nil } }
      let(:authenticatable_info) { nil }

      before {
        allow(PasskeysRails::FinishRegistration)
          .to receive(:call!)
          .with(interactor_context)
          .and_return(Interactor::Context.build(username: "name", auth_token: "123", agent:))
      }

      it_behaves_like "a successful registration"
      it_behaves_like "a notifier", :did_register

      context 'with the optional authenticatable_params' do
        let(:optional_params) { { authenticatable: } }
        let(:authenticatable) { { class: 'User', params: { some: 'more data' } } }
        let(:authenticatable_info) { authenticatable }

        context "when PasskeysRails.default_class is nil" do
          before { PasskeysRails.config.default_class = nil }

          it_behaves_like "a successful registration"
          it_behaves_like "a notifier", :did_register
        end
      end
    end
  end
end
