## メール通知機能を実装する

今回通知を発生させるタイミングは

①フォローされたとき
②自分の投稿にいいねがあった時
③自分の投稿にコメントがあった時

ちなみにこの前の実装でコールバックをい使用して通知機能を実装したがコールバックにメール送信の機能を実装するのは辞めた方が良いらしい。理由としてコンソールやデバッグをした時に気づかないうちにメールが送られていると言う事があるし、コントローラーの方が見通しがよくなるから。ということで今回は解答例通りコントローラーに実装していこうと思います。

[Rails: メールをActive Recordのコールバックで送信しないこと（翻訳）](https://techracho.bpsinc.jp/hachi8833/2019_09_12/76762)

まず最初にメーラーを作成します。

```ruby
rails g mailer UserMailer
```
これでメーラークラスが作成されます。
メーラークラスはコントローラーと作りがかなり似ていて、`ApplicationMiler`を全てのメーラーは継承していてその`ApplicationMailer`は`ApplicationMailer::Base`を継承するところとかは、完全にコントローラーと同じです。

今回`ApplicationMiler`にはデフォルトのメールアドレスを設定しています。

`ApplicationMiler`

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: 'instaclone@example.com'
  layout 'mailer'
end
```

今回は要件に合わせてコントローラーから各リソースが作成された後に、メーラークラスからメールを送信するメソッドを呼び出してメールを送信する形になります。

今回は各リソースが作成された後のタイミングでの通知になるので、各コントローラーの`create`アクションの中で呼び出すことになります。

`relationships_controller`

```ruby
class RelationshipsController < ApplicationController
  def create
    @user = User.find(params[:followed_id])
    UserMailer.with(user_from: current_user, user_to: @user).follow.deliver_later if current_user.follow(@user)
  end
end
```

`likes_controller`

```ruby
class LikesController < ApplicationController
  def create
    post = Post.find(params[:post_id])
    @post = if current_user.like(post)
              UserMailer.with(user_from: current_user, user_to: post.user, post: post).like_post.deliver_later
              post
            end
  end
end
```

`comments_controller`

```ruby
class CommentsController < ApplicationController
  def create
    @comment = current_user.comments.new(comment_params)
    UserMailer.with(user_from: current_user, user_to: @comment.post.user, comment: @comment).comment_post.deliver_later if @comment.save
  end
end
```

このように各コントローラーからメーラークラスに定義したメソッドを呼び出している。withメソッドでメーラークラスに送り先と送り主の情報を渡しています。`deliver_later`メソッドは非同期処理を行う場合に使用するメソッドでメール送信の様に即座に処理する必要が内容な内容に関しては、非同期処理を行う事が多いらしいです。

`UserMailer_.rb`

```ruby
class UserMailer < ApplicationMailer
  def follow
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    mail(to: @user_to, subject: "#{@user_from.username}さんがあなたをフォローしました")
  end

  def comment_post
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    @comment = params[:comment]
    mail(to: @user_to, subject: "#{@user_from.username}さんがあなたの投稿にコメントしました")
  end

  def like_post
    @user_from = params[:user_from]
    @user_to = params[:user_to]
    @post = params[:post]
    mail(to: @user_to, subject: "#{@user_from.username}さんがあなたの投稿にいいねしました")
  end
end

```

このようにコントローラーから`with`メソッドで送った値は`params[:キー]`の形で受け取る事が出来ます。
これをインスタンス変数に格納してコントローラーで言うviewに当たる。メール本文で使用する事が出来ます。

今回はメール本文の指定で、誰が誰にいいねやコメントなどのアクションを行ったかという事を記載するのでインスタンス変数に格納している。

その後に、`mail`メソッドを使用して宛先と、タイトルを指定している。
その他にもオプションはあって下記リンクに書いてました

[【Rails入門】Action Mailerのメール送信を初心者向けに基礎から解説](https://www.sejuku.net/blog/48739)
[Ruby On Rails API メールの所](https://api.rubyonrails.org/classes/ActionMailer/Base.html#method-i-mail)

## メールをブラウザ上で確認する為には

今回メールをブラウザ上で確認する為に、`letter_opener_web`と言うgemを導入しています。

`Gemfile`

```ruby
group: development
  gem 'letter_opener_web'
end
```
で導入。

設定は簡単でまずルーティングを設置してあげる

`routes.rb`

```ruby
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/lo"
  end
```

`at:`以下は基本的になんでも良いアクセスしやすいURLにすればいいと思います。短縮して`/lo`とかでも動きます。
この後に下記の設定をすると`localhost:3000/lo`にアクセスする事でメールを確認する事が出来る様になります。

`config/environment/development.rb`

```ruby
  config.action_mailer.delivery_method = :letter_opener_web
```




## 本文のリンクを開くための設定

メールは確認できる様になったんですが今回メールの本文にはリンクが設定されています。
`link_to`メソッドを使用して設定しているのですが、どうやらHTTPとSMTPではプロトコルが違う為、`host`の値を指定してあげなければいけない様です。

このホスト名の様な定数を管理する為に今回は`config`と言うgemを使います。

このgemですがハードコーディングを避けると言う意味合いがあるのかなと感じました。他はあんまり思いつかなかった。
環境変数ではないけれどハードコーディングしたくないものみたいな感じかな？

とりあえず導入して行きます。

```ruby
gem `config`
```

で導入して、設定ファイルなどを作成します。

```ruby
rails g config:install
```

これで複数の設定用のファイルができます。
詳細は下記リンクに乗っているので割愛します。

今回使うのは、開発環境でのみ使う定数を記載する。`config/settings/development.yml`です。

`development.yml`

```ruby
default_url_options:
  host: 'localhost:3000'
```
とホスト名を記入します。
こうする事で開発環境では、`Settings.default_url_options`と言う表記で使用できます。
今回はハッシュで表現したいので、`Settings.default_url_options.to_h`で`development.rb`に記載します。

`config/environment/development.rb`

```ruby
  config.action_mailer.default_url_options = Settings.default_url_options.to_h
```

中身が気になったのでみてみると

```ruby
[1] pry(main)> Settings.default_url_options
=> #<Config::Options host="localhost:3000">
```

```ruby
[2] pry(main)> Settings.default_url_options.to_h
=> {:host=>"localhost:3000"}
```
`to_h` が必要な事がわかりました。

これでメーラーのテンプレートファイルのリンクも開く事ができる様になります。
