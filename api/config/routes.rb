Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'example/message', to: 'example#message'

  resources :questions, only: [:index, :show]
  post 'questions/ask', to: 'questions#ask'
end
