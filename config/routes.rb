Rails.application.routes.draw do
  root "departments#index"
  resources :departments, only: [:index, :show]
  resources :applicants, only: [:create] do
    post :search, on: :collection
    resources :invitations, only: [:create]
  end
  resources :sessions, only: [:create]
  get '/sign_in', to: "sessions#new"
  delete '/sign_out', to: "sessions#destroy"
end
