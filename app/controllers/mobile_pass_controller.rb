class MobilePassController < MobilePass.parent_controller.constantize
  rescue_from MobilePass::Error, with: :handle_exception

  if respond_to?(:helper_method)
    helpers = %w[current_user authenticate_user!]
    helper_method(*helpers)
  end

  protected

  def current_user
    @_current_user ||= validate_auth_token.user if validate_auth_token.success?
  end

  # Ignoring :reek:MissingSafeMethod
  def authenticate_user!
    fail!(:authentication, validate_auth_token.code, validate_auth_token.message) if validate_auth_token.failure?
  end

  def validate_auth_token
    @_validate_auth_token ||= MobilePass::ValidateAuthToken.call auth_token: headers['X-Auth']
  end

  # Ignoring :reek:MissingSafeMethod
  def fail!(context, code, message)
    raise MobilePass::Error.new(context, code, message)
  end

  # Ignoring :reek:UncommunicativeParameterName
  def handle_exception(e)
    render json: { error: { context: e.context, code: e.code, message: e.message } }, status: :unprocessable_entity
  end
end
