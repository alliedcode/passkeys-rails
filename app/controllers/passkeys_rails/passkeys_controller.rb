module PasskeysRails
  class PasskeysController < ApplicationController
    def challenge
      result = PasskeysRails::BeginChallenge.call!(username: challenge_params[:username])

      # Store the challenge so we can verify the future register or authentication request
      session[:passkeys_rails] = result.session_data

      render json: result.response.as_json
    end

    def register
      result = PasskeysRails::FinishRegistration.call!(credential: attestation_credential_params.to_h,
                                                       authenticatable_class:,
                                                       username: session.dig(:passkeys_rails, :username),
                                                       challenge: session.dig(:passkeys_rails, :challenge))

      render json: { username: result.username, auth_token: result.auth_token }
    end

    def authenticate
      result = PasskeysRails::FinishAuthentication.call!(credential: authentication_params.to_h,
                                                         challenge: session.dig(:passkeys_rails, :challenge))

      render json: { username: result.username, auth_token: result.auth_token }
    end

    def refresh
      result = PasskeysRails::RefreshToken.call!(token: refresh_params[:auth_token])
      render json: { username: result.username, auth_token: result.auth_token }
    end

    protected

    def challenge_params
      params.permit(:username)
    end

    def attestation_credential_params
      credential = params.require(:credential)
      credential.require(%i[id rawId type response])
      credential.require(:response).require(%i[attestationObject clientDataJSON])
      credential.permit(:id, :rawId, :type, { response: %i[attestationObject clientDataJSON] })
    end

    def authenticatable_class
      params[:authenticatable_class]
    end

    def authentication_params
      params.require(%i[id rawId type response])
      params.require(:response).require(%i[authenticatorData clientDataJSON signature userHandle])
      params.permit(:id, :rawId, :type, { response: %i[authenticatorData clientDataJSON signature userHandle] })
    end

    def refresh_params
      params.require(:auth_token)
      params.permit(:auth_token)
    end
  end
end
