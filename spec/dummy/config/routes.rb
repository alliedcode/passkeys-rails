Rails.application.routes.draw do
  mount PasskeysRails::Engine => "/passkeys_rails"
  root to: 'application#index'
  get '/home' => 'application#home'
end
