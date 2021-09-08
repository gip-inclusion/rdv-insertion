Rails.application.routes.draw do
  root "departments#index"
  resources :departments, only: [:index] do
    resources :applicants, only: [:index, :create]
  end

  resources :applicants, only: [] do
    post :search, on: :collection
    resources :invitations, only: [:create]
  end

  resources :sessions, only: [:create]
  get '/sign_in', to: "sessions#new"
  delete '/sign_out', to: "sessions#destroy"

  resources :invitations, only: [] do
    get :redirect, on: :collection
  end
end
