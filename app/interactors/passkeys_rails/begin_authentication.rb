module PasskeysRails
  class BeginAuthentication
    include Interactor

    def call
      context.options = WebAuthn::Credential.options_for_get
    end
  end
end
