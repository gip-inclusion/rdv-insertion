require 'sidekiq/web'

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
  resources :departments, only: [:index] do
    resources :applicants, only: [:index, :create] do
      collection do
        post :search
        resources :uploads, only: [:new]
      end
    end
  end

  resources :applicants, only: [] do
    post :search, on: :collection
    resources :invitations, only: [:create]
  end

  resources :invitations, only: [] do
    get :redirect, on: :collection
  end

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
