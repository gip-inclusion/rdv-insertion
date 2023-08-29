require 'sidekiq/web'
require 'sidekiq/cron/web'

def check_auth(username, password, service)
  ActiveSupport::SecurityUtils.secure_compare(
    Digest::SHA256.hexdigest(username),
    Digest::SHA256.hexdigest(ENV["#{service}_USERNAME"])
  ) & ActiveSupport::SecurityUtils.secure_compare(
    Digest::SHA256.hexdigest(password),
    Digest::SHA256.hexdigest(ENV["#{service}_PASSWORD"])
  )
end

Rails.application.routes.draw do
  root "static_pages#welcome"
  get "mentions-legales", to: "static_pages#legal_notice"
  get "cgu", to: "static_pages#cgu"
  get "politique-de-confidentialite", to: "static_pages#privacy_policy"
  get "accessibilite", to: "static_pages#accessibility"

  resources :teleprocedure_landings, param: "department_number",
                                     path: '/parcours_insertion',
                                     only: [:show]

  resources :organisations, only: [:index, :new, :show, :edit, :create, :update] do
    get :geolocated, on: :collection
    get :search, on: :collection
    resources :applicants, only: [:index, :create, :show, :update, :edit, :new] do
      collection do
        resources :uploads, only: [:new]
        get "uploads/category_selection", to: "uploads#category_selection"
        get :default_list
      end
      resources :invitations, only: [:create]
    end
    # we need to nest in organisations the different configurations record to correctly authorize them
    resources :configurations, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :tags, only: [:create, :destroy]
    resources :file_configurations, only: [:show, :new, :create, :edit, :update] do
      get :confirm_update
    end
    resources :messages_configurations, only: [:show, :new, :edit, :create, :update]
  end

  resources :stats, only: [:index, :show] do
    get :deployment_map, on: :collection
  end

  get "invitation", to: "invitations#invitation_code", as: :invitation_landing
  resources :invitations, only: [] do
    get :redirect, on: :collection
  end

  resources :convocations, only: [:new]

  resources :rdv_contexts, only: [:create]

  resources :rdv_contexts, module: :rdv_contexts, only: [] do
    resource :closings, only: [:create, :destroy]
  end

  namespace :applicants do
    resources :searches, only: :create
  end

  resources :archives, only: [:create, :destroy]

  namespace :organisations do
    resources :applicant_added_notifications, only: [:create]
  end

  resources :participations, only: [] do
    resources :notifications, only: :create
  end

  namespace :previews do
    resources :invitations, only: [:index]
    resources :notifications, only: [:index]
  end

  namespace :carnet_de_bord do
    resources :carnets, only: [:create]
  end

  resources :departments, only: [] do
    resources :department_organisations, only: [:index], as: :organisations, path: "/organisations"
    resources :applicants, only: [:index, :new, :create, :show, :edit, :update] do
      collection do
        resources :uploads, only: [:new]
        get "uploads/category_selection", to: "uploads#category_selection"
        get :default_list
      end
      resources :invitations, only: [:create]
      resources :applicants_organisations, only: [:index]
      resources :referent_assignations, only: [:index]
    end
    resource :applicants_organisations, only: [:create, :destroy]
    resource :referent_assignations, only: [:create, :destroy]
  end
  resources :invitation_dates_filterings, :creation_dates_filterings, only: [:new]
  resources :tags_filterings, :tags_filterings, only: [:new]

  namespace :api do
    namespace :v1 do
      resources :organisations, param: "rdv_solidarites_organisation_id", only: [] do
        member do
          resources :applicants, only: [] do
            post :create_and_invite_many, on: :collection
          end
          post "users/create_and_invite_many", to: "applicants#create_and_invite_many"
        end
      end
    end
  end

  # Error pages
  get "404", to: "errors#not_found"
  get "422", to: "errors#unprocessable_entity"
  get "500", to: "errors#internal_server_error"

  resources :rdv_solidarites_webhooks, only: [:create]

  resources :sessions, only: [:create]
  get '/sign_in', to: "sessions#new"
  delete '/sign_out', to: "sessions#destroy"

  get "inclusion_connect/auth" => "inclusion_connect#auth"
  get "inclusion_connect/callback" => "inclusion_connect#callback"

  if ENV["SIDEKIQ_USERNAME"] && ENV["SIDEKIQ_PASSWORD"]
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      check_auth(username, password, "SIDEKIQ")
    end
  end
  mount Sidekiq::Web, at: "/sidekiq"

  if Rails.env.development?
    # LetterOpener
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
