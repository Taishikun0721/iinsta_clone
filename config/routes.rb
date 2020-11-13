Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'users#new'

  resources :users, only: [:index, :show, :new, :create]
  # shallowルーティングを使用すると、必ずネストが必要な(紐づけられたものを表示or作成するから)indexとcreate以外のネストを無くしてくれる。
  resources :posts, shallow: true do
    resources :comments, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :relationships, only: [:create, :destroy]
  resources :likes, only: %i[create destroy]
  get '/login', to: 'user_sessions#new'
  post '/login', to: 'user_sessions#create'
  delete '/logout', to: 'user_sessions#destroy'
end
