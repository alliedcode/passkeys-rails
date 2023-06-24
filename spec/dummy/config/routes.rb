Rails.application.routes.draw do
  mount MobilePass::Engine => "/mobile_pass"
  root to: 'application#index'
  get '/home' => 'application#home'
end
