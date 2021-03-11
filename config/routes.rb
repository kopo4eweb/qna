# frozen_string_literal: true

Rails.application.routes.draw do
  resources :questions do
    resource :answers, only: :create
  end
end
