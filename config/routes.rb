Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get 'stations/meteostations', to: 'stations#meteostations'
  get 'stations/hydroposts', to: 'stations#hydroposts'
  resources :stations
  get 'observations/observations', to: 'observations#observations'
  resources :observations
  get 'conservations/save_hydro_data', to: 'conservations#save_hydro_data'
  resources :conservations
end
