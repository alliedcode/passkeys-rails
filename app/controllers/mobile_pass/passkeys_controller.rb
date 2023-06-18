class MobilePass::PasskeysController < MobilePassController
  def challenge
    result = MobilePass::BeginChallenge.call!(username: challenge_params[:username])

    # Store the challenge so we can verify the future register or authentication request
    session[:mobile_pass] = result.session_data

    render json: result.response.as_json
  end

  def register
    result = MobilePass::FinishRegistration.call!(credential: credential_params,
                                                  username: session[:username],
                                                  challenge: session[:challenge])

    render json: { username: result.username, auth_token: result.auth_token }
  end

  def authenticate
    result = MobilePass::FinishAuthentication.call!(credential: credential_params,
                                                    challenge: session[:challenge])

    render json: { username: result.username, auth_token: result.auth_token }
  end

  def refresh
    result = MobilePass::RefreshToken.call!(token: refresh_params[:auth_token])
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
