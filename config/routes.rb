Rails.application.routes.draw do
  post '/login', to: 'auth#login'
  post '/signup', to: 'auth#signup'
  post '/logout', to: 'auth#logout'

  # will uncomment this when emails are working
  # post '/password/forgot', to: 'passwords#forgot'
  # post '/password/reset', to: 'passwords#reset'

  # get "pages/home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  resources :users, only: [:show, :update]

  resources :posts do
    resources :comments, only: [:create, :show, :destroy]
  end

  scope :profile do
    get '/', to: 'users#show'
    get '/posts', to: 'users#posts'
    patch '/', to: 'users#update'
    patch '/update_password', to: 'users#update_password'
  end
end
