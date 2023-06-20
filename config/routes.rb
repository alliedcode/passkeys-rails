MobilePass::Engine.routes.draw do
  post 'passkeys/challenge'
  post 'passkeys/register'
  post 'passkeys/authenticate'
  post 'passkeys/refresh'
end
