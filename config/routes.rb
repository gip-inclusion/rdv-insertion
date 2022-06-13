require 'sidekiq/web'
require 'sidekiq-cron'

def check_auth(username, password, service)
  ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(username),
    ::Digest::SHA256.hexdigest(ENV["#{service}_USERNAME"])
  ) & ActiveSupport::SecurityUtils.secure_compare(
    ::Digest::SHA256.hexdigest(password),
    ::Digest::SHA256.hexdigest(ENV["#{service}_PASSWORD"])
  )
end

Rails.application.routes.draw do
  root "static_pages#welcome"
  get "mentions-legales", to: "static_pages#legal_notice"
  get "politique-de-confidentialite", to: "static_pages#privacy_policy"
  get "accessibilite", to: "static_pages#accessibility"

  resources :teleprocedure_landings, param: "department_number",
                                     path: '/parcours_insertion',
                                     only: [:show]

  resources :organisations, only: [:index] do
    get :geolocated, on: :collection
    resources :applicants, only: [:index, :create, :show, :update, :edit, :new] do
      collection do
        resources :uploads, only: [:new]
        post :search
      end
      resources :invitations, only: [:create]
    end
  end

  resources :stats, only: [:index, :show] do
    get :deployment_map, on: :collection
  end

  get "invitation", to: "invitations#invitation_code", as: :invitation_landing
  resources :invitations, only: [] do
    get :redirect, on: :collection
  end

  resources :applicants, only: [] do
    resources :rdv_contexts, only: [:create]
    post :search, on: :collection
  end

  resources :departments, only: [] do
    resources :applicants, only: [:index, :new, :create, :show, :edit, :update] do
      collection { resources :uploads, only: [:new] }
      resources :invitations, only: [:create]
      resources :applicants_organisations, only: [:new, :create]
    end
  end

  namespace :api do
    namespace :v1 do
      resources :organisations, param: "rdv_solidarites_organisation_id", only: [] do
        member do
          resources :applicants, only: [] do
            post :create_and_invite_many, on: :collection
          end
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

  if ENV["SIDEKIQ_USERNAME"] && ENV["SIDEKIQ_PASSWORD"]
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      check_auth(username, password, "SIDEKIQ")
    end
  end
  mount Sidekiq::Web, at: "/sidekiq"
end
