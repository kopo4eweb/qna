# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  resources :attachments, only: :destroy

  resources :questions do
    resources :answers, shallow: true, only: %i[create update destroy] do
      member do
        patch :select_best
      end
    end
  end

  root to: 'questions#index'
end
