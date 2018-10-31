Rails.application.routes.draw do
  resources :transactions
  resources :members
  get '/whatsapp' => 'webhooks#whatsapp'
  post '/whatsapp' => 'webhooks#whatsapp'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
