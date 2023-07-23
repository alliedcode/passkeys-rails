# These should be autoloaded, but if these aren't required here, apps using this
# gem will throw an exception that Passkeys::Rails::Authentication can't be found
require_relative '../../app/controllers/concerns/passkeys/rails/authentication'
require_relative '../../app/models/passkeys/rails/error'

class ActionController::Base
  include Passkeys::Rails::Authentication
end

class ActionController::API
  include Passkeys::Rails::Authentication
end
