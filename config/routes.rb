Rails.application.routes.draw do
  root "boards#show"

  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]
  resource :guest, only: :create
  resources :passwords, param: :token, only: %i[ new create edit update ]

  resources :workers, only: %i[ create destroy ]
  resources :tasks, only: %i[ create destroy ] do
    resource :progress, only: :update, module: :tasks
  end
  resource :worker_order, only: :update
  resource :task_order, only: :update

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
