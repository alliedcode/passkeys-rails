class MobilePass::PasskeysController < MobilePassController
  def challenge
    username = challenge_params[:username]

    result = MobilePass::BeginChallenge.call(username:)

    fail!(:authentication, result.code, result.message) if result.failure?

    # Store the challenge so we can verify the future register or authentication request
    session[:mobile_pass] = result.session_data

    render json: result.response.as_json
  rescue StandardError => e
    fail!(:authentication, :other, e.message)
  end

  def register
    result = MobilePass::FinishRegistration.call(credential: credential_params,
                                                 username: session[:username],
                                                 challenge: session[:challenge])

    fail!(:authentication, result.code, result.message) if result.failure?

    render json: { username: result.username, auth_token: result.auth_token }
  end

  def authenticate
    result = MobilePass::FinishAuthentication.call(credential: credential_params,
                                                   challenge: session[:challenge])

    fail!(:authentication, result.code, result.message) if result.failure?

    render json: { username: result.username, auth_token: result.auth_token }
  end

  def refresh
    result = MobilePass::RefreshToken(token: refresh_params[:auth_token])

    fail!(:authentication, result.code, result.message) if result.failure?

    render json: { username: result.username, auth_token: result.auth_token }
  end

  protected

  def challenge_params
    params.permit(:username)
  end

  def credential_params
    params.require(:id, :rawId, :type, response: %i[attestationObject clientDataJSON])
  end

  def refresh_params
    params.require(:auth_token)
  end
end
