Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'posts#index'

  require 'sidekiq/web'
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
    mount Sidekiq::Web, at: "/sidekiq"
  end
  # letter_openerの設定。これでhttp://localhost:3000/letter_openerにアクセスするとメールが見る事ができる。

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
    resources :activities, only: :index
  end
  # 今回はmypage以下に自分への通知一覧画面を作成したいのでmypage以下にルーティングを設定する。
  # mypage以下に色々とファイルを作成するのでnamespaceを切る。自分アカウントに関する機能を追加する際はこの下に追加していく。

  resources :activities, only: [] do
    resource :read, only: :create
  end

  resources :relationships, only: [:create, :destroy]
  resources :likes, only: [:create, :destroy]
  get '/login', to: 'user_sessions#new'
  post '/login', to: 'user_sessions#create'
  delete '/logout', to: 'user_sessions#destroy'
end
