# frozen_string_literal: true

Rails.application.routes.draw do
  root 'sessions#new'
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token
  resources :admin, only: %i[index new create] # will get create
  resources :dashboard, only: %i[index] # might get changed to show (for token)
  resources :ms_authenticate, only: %i[index new]
  resources :test, only: %i[index] # name will be changed
  resources :user, only: %i[show]
  get "up" => "rails/health#show.html.erb", as: :rails_health_check
end
