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
  namespace :super_admins do
    resources :agents, only: [:index, :show] do
      resource :impersonation, only: [:create, :destroy]
    end
    resources :departments, only: [:index, :show, :new, :create, :edit, :update]
    resources :organisations, only: [:index, :show, :new, :create, :edit, :update]
    resources :users, only: [:index, :show, :edit, :update]
    resources :motif_categories, only: [:index, :show, :new, :create, :edit, :update]
    resources :templates, only: [:index, :show]
    resources :orientation_types, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :webhook_endpoints, only: [:index] do
      post :duplicate, on: :member
    end
    resources :blocked_invitations_counters, only: [:index]
    resources :blocked_users, only: [:index]

    root to: "agents#index"
  end
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'

  get '/sign_in', to: 'sessions#new'
  get 'auth/:provider/callback', to: 'sessions#create'

  resources :super_admin_authentication_requests, only: [:create]
  resources :super_admin_authentication_request_verifications, only: [:new, :create]

  scope module: 'website' do
    root "static_pages#welcome"
    get "mentions-legales", to: "static_pages#legal_notice"
    get "cgu", to: "static_pages#cgu"
    get "politique-de-confidentialite", to: "static_pages#privacy_policy"
    get "accessibilite", to: "static_pages#accessibility"

    resources :teleprocedure_landings, param: "department_number",
                                       path: '/parcours_insertion',
                                       only: [:show]
  end

  # CSP endpoints
  get "/csp-test", to: "content_security_policy#test"
  post "/csp-test-endpoint", to: "content_security_policy#test_endpoint"
  post "/csp-violation-report", to: "content_security_policy#report"

  get "/organisations", to: "organisations#index", as: :authenticated_root

  resources :notification_center, only: [:index]
  resource :cookies_consent, only: [:new, :create, :update, :edit]

  resources :organisations, only: [:index, :show, :edit, :update] do
    get :geolocated, on: :collection
    get :search, on: :collection

    member do
      get :show_data_retention
      get :edit_data_retention
      patch :update_data_retention
    end
    resources :convocations, only: [:new]
    scope module: :user_list_uploads do
      resources :user_list_uploads, only: [:new, :create] do
        post :create_from_existing_users, on: :collection
      end
    end
    namespace :user_list_uploads do
      resources :category_selections, only: [:new]
    end
    resource :configuration, only: [:show]

    scope module: :organisations do
      namespace :configuration do
        resource :informations, only: [:show]
        resource :agents, only: [:show]
        resource :categories, only: [:show]
        resource :messages, only: [:show]
        resource :tags, only: [:show]
      end
    end
    resources :dpa_agreements, only: :create, module: :organisations
    resources :users, only: [:index, :create, :show, :update, :edit, :new] do
      collection do
        get :default_list
        scope module: :users do
          resources :uploads, only: [:new]
          get "uploads/category_selection", to: "uploads#category_selection"
        end
      end
      scope module: :users do
        resources :follow_ups, only: [:index]
        resource :parcours, only: [:show]
      end
      resources :archives, only: [:new, :create]
      resources :invitations, only: [:create]
    end
    resources :archives, only: [:destroy]
    resources :follow_ups, module: :follow_ups, only: [] do
      resource :closings, only: [:create, :destroy]
    end
    # we need to nest in organisations the different category_configurations record to correctly authorize them
    resources :category_configurations, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        get :edit_rdv_preferences
        patch :update_rdv_preferences
        get :edit_messages
        patch :update_messages
        get :edit_notifications
        patch :update_notifications
      end
    end
    patch "category_configurations_positions/update", to: "category_configurations_positions#update"
    resources :tags, only: [:create, :destroy]
    resources :agent_roles, module: :agent_roles, only: [] do
      collection do
        resources :csv_export_authorizations, only: [:index]
        patch "csv_export_authorizations/batch_update", to: "csv_export_authorizations#batch_update"
      end
    end
    scope module: :dates_filterings do
      resources :choose_date_kind,
                :invitation_dates_filterings,
                :convocation_dates_filterings,
                :creation_dates_filterings, only: [:new]
    end
    resources :messages_configurations, only: [:show, :new, :edit, :create, :update]
  end

  resources :user_list_uploads, module: :user_list_uploads, only: [:show] do
    post :enrich_with_cnaf_data

    resources :user_rows, only: [:update, :show] do
      get :show_details
      get :hide_details
      resource :user_row_cells, only: [:edit]
      post :batch_update, on: :collection

      resources :organisation_assignations, only: [:new, :create]

      namespace :user_save_attempts do
        resources :retries, only: [:new, :create]
      end

      namespace :invitation_attempts do
        resources :retries, only: [:new, :create]
      end
    end

    resources :user_save_attempts, only: [:index, :create] do
      post :create_many, on: :collection
    end
    resources :invitation_attempts, only: [:index, :create] do
      get :select_rows, on: :collection
      post :create_many, on: :collection
    end
  end
  resources :accept_cgus, only: [:create]
  resources :file_configurations, only: [:show, :new, :create, :edit, :update] do
    get :download_template
  end

  resources :users, module: :users, only: [] do
    resources :rdvs, only: [:new]
    resources :parcours_documents, only: [:show, :update, :create, :destroy]
    resources :tag_assignations, only: [:index, :create, :destroy], param: :tag_id
    resources :referent_assignations, only: [:index, :create, :destroy], param: :agent_id
    resources :orientations, only: [:new, :create, :edit, :update, :destroy]
  end

  get "invitation", to: "invitations#invitation_code", as: :invitation_landing
  get '/r/:uuid', to: "invitations#redirect_shortcut", as: :redirect_invitation_shortcut
  resources :invitations, only: [] do
    get :redirect, on: :collection
  end

  resources :csv_exports, only: :show

  resources :participations, only: [:update]
  resources :follow_ups, only: [:create]
  resources :users_organisations, only: [:index, :create]
  resource :users_organisations, only: [:destroy]

  namespace :users do
    resources :searches, only: :create
  end

  resources :participations, only: [] do
    resources :notifications, only: :create
  end

  namespace :previews do
    resources :invitations, only: [:index]
    resources :notifications, only: [:index]
    resources :signature_images, only: [:show]
  end

  resources :departments, only: [] do
    patch "category_configurations_positions/update", to: "category_configurations_positions#update"
    resources :department_organisations, only: [:index], as: :organisations, path: "/organisations"
    resources :convocations, only: [:new]
    scope module: :user_list_uploads do
      resources :user_list_uploads, only: [:new, :create] do
        post :create_from_existing_users, on: :collection
      end
    end
    namespace :user_list_uploads do
      resources :category_selections, only: [:new]
    end
    resources :users, only: [:index, :new, :create, :show, :edit, :update] do
      collection do
        scope module: :users do
          resources :uploads, only: [:new]
          get "uploads/category_selection", to: "uploads#category_selection"
        end
        get :default_list
      end
      scope module: :users do
        resources :follow_ups, only: [:index]
        resource :parcours, only: [:show]
      end
      resources :invitations, only: [:create]
      resources :archives, only: [] do
        get :new_batch, on: :collection
        post :create_many, on: :collection
      end
    end
    resources :follow_ups, module: :follow_ups, only: [] do
      resource :closings, only: [:create, :destroy]
    end

    resources :users_organisations, only: [:index, :create]
    resource :users_organisations, only: [:destroy]

    resources :organisations, only: [] do
      resources :user_added_notifications, only: [:create], controller: 'organisations/user_added_notifications'
    end

    scope module: :dates_filterings do
      resources :choose_date_kind,
                :invitation_dates_filterings,
                :convocation_dates_filterings,
                :creation_dates_filterings, only: [:new]
    end
  end

  resources :departments, only: [], param: :id_for_stats do
    resource :stats, only: [:show], controller: 'website/stats'
  end

  resources :organisations, only: [], param: :id_for_stats do
    resource :stats, only: [:show], controller: 'website/stats'
  end

  resources :stats, only: [:index], controller: 'website/stats' do
    get :deployment_map, on: :collection
  end

  namespace :api do
    namespace :v1 do
      resources :departments, param: "department_number", only: [:show]
      resources :rdvs, param: "uuid", only: [:show]
      resources :organisations, param: "rdv_solidarites_organisation_id", only: [] do
        member do
          resources :users, only: [:index, :create] do
            collection do
              post :create_and_invite_many
              post :create_and_invite
            end
            member do
              post :invite
            end
          end
          post "applicants/create_and_invite_many", to: "users#create_and_invite_many"
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
  get '/sign_out', to: "sessions#destroy"

  post "/inbound_emails/brevo", to: "inbound_emails#brevo"
  namespace :brevo do
    post "mail_webhooks", to: "mail_webhooks#create"
    post "sms_webhooks/:record_identifier", to: "sms_webhooks#create", as: :sms_webhooks
  end

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
