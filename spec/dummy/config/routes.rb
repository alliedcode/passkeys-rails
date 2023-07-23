Rails.application.routes.draw do
  mount Passkeys::Rails::Engine => "/passkeys_rails"
  root to: 'application#index'
  get '/home' => 'application#home'
end
