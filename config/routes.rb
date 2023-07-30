PasskeysRails::Engine.routes.draw do
  post 'challenge', to: 'passkeys#challenge'
  post 'register', to: 'passkeys#register'
  post 'authenticate', to: 'passkeys#authenticate'
  post 'refresh', to: 'passkeys#refresh'

  # These routes exist to allow easier mobile app debugging as it may not
  # be possible to acess Passkey functionality in mobile simulators.
  # CAUTION: It is very insecure to set DEBUG_LOGIN_REGEX in a production environment.
  constraints(->(_request) { PasskeysRails.debug_login_regex.present? }) do
    post 'debug_login', to: 'passkeys#debug_login'
    post 'debug_register', to: 'passkeys#debug_register'
  end
end
