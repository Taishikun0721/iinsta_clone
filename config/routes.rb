Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'posts#index'

  resources :users, only: [:index, :show, :new, :create]
  # shallowルーティングを使用すると、必ずネストが必要な(紐づけられたものを表示or作成するから)indexとcreate以外のネストを無くしてくれる。
  resources :posts, shallow: true do
    # クエリパラメータで検索するワードを送るのでGETメソッド, get :search, on: :collectionでも同じ
    collection do
      get :search
    end
    resources :comments, only: [:new, :create, :edit, :update, :destroy]
  end

  namespace :mypage do
    resource :account, only: [:edit, :update]
  end
  # mypage以下に色々とファイルを作成するのでnamespaceを切る。自分アカウントに関する機能を追加する際はこの下に追加していく。

  resources :relationships, only: [:create, :destroy]
  resources :likes, only: [:create, :destroy]
  get '/login', to: 'user_sessions#new'
  post '/login', to: 'user_sessions#create'
  delete '/logout', to: 'user_sessions#destroy'
end
