Rails.application.routes.draw do
  post 'challenge' => 'mobile_pass/passkeys#challenge'
  post 'register' => 'mobile_pass/passkeys#register'
  post 'authenticate' => 'mobile_pass/passkeys#authenticate'
  post 'refresh' => 'mobile_pass/passkeys#refresh'
end
