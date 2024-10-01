module PasskeysRails
  class PasskeysController < ApplicationController
    skip_before_action :verify_authenticity_token
    wrap_parameters false

    def challenge
      result = PasskeysRails::BeginChallenge.call!(username: challenge_params[:username])

      # Store the challenge so we can verify the future register or authentication request
      cookies.signed[:passkeys_rails] = {
        value: result.cookie_data.to_json,
        expire: Time.now.utc + (result.response.timeout / 1000),
        secure: true,
        httponly: true,
        same_site: :strict
      }

      render json: result.response.as_json
    end

    def register
      cookie_data = JSON.parse(cookies.signed["passkeys_rails"] || "{}")
      result = PasskeysRails::FinishRegistration.call!(credential: attestation_credential_params.to_h,
                                                       authenticatable_info: authenticatable_params&.to_h,
                                                       username: cookie_data["username"],
                                                       challenge: cookie_data["challenge"])

      broadcast(:did_register, agent: result.agent)

      render json: auth_response(result)
    end

    def authenticate
      cookie_data = JSON.parse(cookies.signed["passkeys_rails"] || "{}")
      result = PasskeysRails::FinishAuthentication.call!(credential: authentication_params.to_h,
                                                         challenge: cookie_data["challenge"])

      broadcast(:did_authenticate, agent: result.agent)

      render json: auth_response(result)
    end

    def refresh
      result = PasskeysRails::RefreshToken.call!(token: refresh_params[:auth_token])

      broadcast(:did_refresh, agent: result.agent)

      render json: auth_response(result)
    end

    # This action exists to allow easier mobile app debugging as it may not
    # be possible to acess Passkey functionality in mobile simulators.
    # It is only routable if DEBUG_LOGIN_REGEX is set in the server environment.
    # CAUTION: It is very insecure to set DEBUG_LOGIN_REGEX in a production environment.
    def debug_login
      result = PasskeysRails::DebugLogin.call!(username: debug_login_params[:username])

      broadcast(:did_authenticate, agent: result.agent)

      render json: auth_response(result)
    end

    # This action exists to allow easier mobile app debugging as it may not
    # be possible to acess Passkey functionality in mobile simulators.
    # It is only routable if DEBUG_LOGIN_REGEX is set in the server environment.
    # CAUTION: It is very insecure to set DEBUG_LOGIN_REGEX in a production environment.
    def debug_register
      result = PasskeysRails::DebugRegister.call!(username: debug_login_params[:username],
                                                  authenticatable_info: authenticatable_params&.to_h)

      broadcast(:did_register, agent: result.agent)

      render json: auth_response(result)
    end

    protected

    def auth_response(result)
      { username: result.username, auth_token: result.auth_token }
    end

    def challenge_params
      params.permit(:username)
    end

    def attestation_credential_params
      credential = params.require(:credential)
      credential.require(%i[id rawId type response])
      credential.require(:response).require(%i[attestationObject clientDataJSON])
      credential.permit(:id, :rawId, :type, { response: %i[attestationObject clientDataJSON] })
    end

    def authenticatable_params
      params.require(:authenticatable).permit(:class, params: {}) if params[:authenticatable].present?
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

    def debug_login_params
      params.require(:username)
      params.permit(:username)
    end

    def broadcast(event_name, agent:)
      ActiveSupport::Notifications.instrument("passkeys_rails.#{event_name}", { agent:, request: })
    end
  end
end
