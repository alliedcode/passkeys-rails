module PasskeysRails
  class ApplicationController < ActionController::Base
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ::Interactor::Failure, with: :handle_interactor_failure
    rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

    protected

    def handle_standard_error(error)
      render_error(:authentication, 'error', error.message.truncate(512), status: 500)
    end

    def handle_missing_parameter(error)
      render_error(:authentication, 'missing_parameter', error.message)
    end

    def handle_interactor_failure(failure)
      render_error(:authentication, failure.context.code, failure.context.message)
    end

    private

    def render_error(context, code, message, status: :unprocessable_entity)
      render json: { error: { context:, code:, message: } }, status:
    end
  end
end
