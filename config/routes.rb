Rails.application.routes.draw do
  resources :members
  get '/webhook/whatsapp' => 'webhooks#whatsapp'
  post '/webhook/whatsapp' => 'webhooks#whatsapp'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
