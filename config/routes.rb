Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get 'stations/meteostations', to: 'stations#meteostations'
  get 'stations/hydroposts', to: 'stations#hydroposts'
  resources :stations
end
