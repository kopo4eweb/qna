# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  get '/load-gist', to: 'gists#load'

  resource :reward, only: :show
  resources :attachments, only: :destroy
  resources :links, only: :destroy

  concern :votable do
    member do
      post :vote_up
      post :vote_down
      delete :cancel_vote
    end
  end

  concern :commentable do
    member do
      post :add_comment
    end
  end

  resources :questions, concerns: %i[votable commentable] do
    resources :answers, shallow: true, only: %i[create update destroy], concerns: %i[votable commentable] do
      member do
        patch :select_best
      end
    end
  end

  root to: 'questions#index'
end
