# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :questions do
    resource :answers, only: :create
  end

  root to: 'questions#index'
end
