Rails.application.routes.draw do
  # Defines the root path route ("/")
  # root "articles#index"
  get 'example/message', to: 'example#message'

  resources :questions, only: [:show]
  post 'questions/ask', to: 'questions#ask'

  match "*path", to: "application#fallback_index_html", via: :all
end
