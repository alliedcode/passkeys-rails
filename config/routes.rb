PasskeysRails::Engine.routes.draw do
  post 'passkeys/challenge'
  post 'passkeys/register'
  post 'passkeys/authenticate'
  post 'passkeys/refresh'

  # This route exists to allow easier mobile app debugging as it may not
  # be possible to acess Passkey functionality in mobile simulators.
  # CAUTION: It is very insecure to set DEBUG_LOGIN_REGEX in a production environment.
  constraints(->(_request) { PasskeysRails.debug_login_regex.present? }) do
    post 'passkeys/debug_login'
  end
end
