# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper

  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks' }

  namespace :api do
    namespace :v1 do
      resources :profiles, only: [] do
        get :me, on: :collection
        get :users_without_me, on: :collection
      end
      resources :questions
    end
  end

  get '/user/email', to: 'users#email', as: 'email'
  post '/user/set_email', to: 'users#set_email', as: 'set_email'

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
