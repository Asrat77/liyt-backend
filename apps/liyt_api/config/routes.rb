Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  namespace :auth do
    resource :sessions, only: [ :create ] do
      post :refresh
      post :revoke
    end

    resource :registrations, only: [ :create ]
    resource :me, only: [ :show ]
  end

  namespace :drivers do
    resource :sessions, only: [ :create ] do
      post :refresh
      post :revoke
    end
    resource :registrations, only: [ :create ]
    resource :me, only: [ :show ]

    resources :deliveries, only: [ :index, :show ] do
      collection do
        get :history
      end
      member do
        patch :accept
        patch :pickup
        patch :complete
      end
    end
  end

  resources :business_locations, only: [ :index, :show, :create, :update, :destroy ]
  resource :business_settings, only: [ :show, :update ]

  resources :api_keys, only: [ :index, :show, :create ] do
    member do
      patch :revoke
      patch :rotate
    end
  end

  resources :deliveries, only: [ :index, :show, :create ] do
    member do
      patch :cancel
    end
  end

  namespace :customers do
    resource :sessions, only: [ :create ] do
      post :refresh
      post :revoke
    end
    resource :registrations, only: [ :create ]
    resource :me, only: [ :show ]

    get "confirmation", to: "confirmations#show"
    post "confirmation/confirm", to: "confirmations#confirm"
  end

  get "track/:token", to: "tracking#show", as: :tracking

  # Defines the root path route ("/")
  # root "posts#index"
end
