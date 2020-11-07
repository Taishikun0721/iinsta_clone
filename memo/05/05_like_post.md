# 05_like_postまとめ

## Like機能を実装する

Like機能を実装するためには、まずlikesテーブルを作成する。

1. likeはどのユーザーがlikeするか
2. どのpostにlikeするか

の2つが分かればDB上で管理できる。likesテーブルはそのためuser_idとpost_idふたつの外部キーを持つことになる。また、1人のユーザーが1つのポストに対して1回しかできない使用にしたいので**user_id**と**post_id**で複合ユニークキーを設定する必要がある。

`マイグレーションファイル`

```
add_index :likes, [user_id, post_id], unique: true
```
これでDB側の設定を修正したのでバリデーションも設定する。
コメントでも書いたがuser_idだけでは全体でuser_idがユニークになってしまうので
scopeでpost_idを指定しする事で,postに対してのユニークという様に設定できる

`like.rb`

```
validates :user_id, uniqueness { scope: :post_id }
```
これでDBの制約とバリデーションは設定完了。
次は各テーブルとのアソシエーションを追加する

`like.rb`

```
belongs_to :user
belongs_to :post
```

ここはそのままでuserとpostの外部キーを持っているので、このように記述する。

`user.rb`

```
has_many :likes, dependent: :destroy
has_many :like_posts, through: :likes, source: :posts
```

上の関連の意味は
1. userが削除されたら、削除されたユーザーがしたlikeは消す
2. `user.like_posts` でユーザーがlikeしたpostsが取得できる

`post.rb`

```
has_many :likes, dependent: :destroy
has_many :like_users, through: :likes, source: :users
```

上の関連の意味は
1. userが削除されたら、削除されたユーザーがしたlikeは消す
2. `post.like_users` でpostにがlikeしたusersが取得できる

ただの`has_many :posts`とかだと単純にuserが投稿したpostsが取得できるだけなので明確に分ける必要がある。

ちなみ, 今回`like_posts`や`like_users`という別名を付けている場合はテーブル名を`source`オプションで
指定する必要がある。

なんとなくですが、この前のプルリクで議論になった、中間テーブルと呼ぶかどうかですが
has_many :throughで先のテーブルを取りに行ったとき自然（いい表現がわからない）かどうかみたいなとこもあるのかなと思った。ほんとになんとなくだが確かにコメントはリソース系の様な気もする笑※曖昧ですんません笑
なんていうか、コメントの方が実態があると言ったらいいのかな。。

likeはされてるかされてないかで判断できるけれど、コメントはbodyをもっているからより具体的でリソースよりみたいな笑

とりあえず次行きます！


次はlikes_controllerを作成する

```
rails g controller likes
```
今回は、likeしたかしてないかなので、アクションは2つでOK

```
def create
  post = Post.find(params[post_id])
  @post = current_user.like(post)
end

def destroy
  post = Like.find(params[:id]).post
  @post = current_user.unlike(post)
end

```
今回のオレオレ実装として、後述のlikeのカウンターを付けたので解答例とは違う書き方になっている。
reloadした結果が、`@post`に入る様にしている。

`user.rb`

```
  def like(post)
    like_posts << post
    post.reload
  end

  def unlike(post)
    like_posts.destroy(post)
    post.reload
  end
```

今回`@post`に値を格納しているのはDBに変更(like or unlike)を加える前だったので
`@post`が変更された段階でSQLが走ってカウントアップ、ダウンされる為、最初に格納した段階のインスタンス変数にはカウントが更新されていない。
※変更 == like, unlikeの事

なので今回はuserモデルの中で`reload`メソッドを使用して最新の状態にしている
※SQLを見る限りUser.find(params[:id])と一緒だった。

つまり1回分多くSQLを発生させている状態になってしまった。
不本意だったが、別の責務を持ったオブジェクトだと思ったのでこのままで良いかなとも少し思う。

1. likeを作成、更新させるためのオブジェクト（ローカル変数）
2. viewで情報を表示させるためのオブジェクト (インスタンス変数)

みたいな責務のイメージで実装しました。

とりあえずいいねにはカウントがないと人気とかわからへんやん！！という
あまりSNS使わない僕のユーザー視点の要望は達成できたのでそこは満足です笑


■参考資料

[Active Record の関連付け](https://railsguides.jp/association_basics.html#has-many%E3%81%A7%E8%BF%BD%E5%8A%A0%E3%81%95%E3%82%8C%E3%82%8B%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89)
[【Rails】多対多のアソシエーションに別名をつけたいあなたに](https://kimuraysp.hatenablog.com/entry/2017/09/05/235816)
[[Rails] [RDB] キー・複合キーをきちんと利用する](https://qiita.com/qsona/items/738be3c9f69d0818944f)
[ActiveRecord::Base#reloadの使い方](http://totutotu.hatenablog.com/entry/2015/11/18/083300)



## likeの数をカウントする

likeのカウントを数えたいのでここではgemの`counter_culture`を使用する。
`counter_cache`というRails標準の機能もあるが、これは今データ作成の時と同一トランザクション内で
行われれるため、**デッドロック**といういかにもやばそうな事が起こるらしい。

デッドロックを調べてみた結果を簡単にまとめると

1. 基本的にDBに更新が加わる時は、対象のレコードをロックする。（他のユーザーに更新されないようにする）
2. ロックされたレコードは他のユーザーがアクセスしてもロック解除待ち（更新待ち）になる
3. 通常の場合、ロック待ちになるので問題ない。ただトランザクション機能を使用して複数のレコードをロックする必要があった場合、同タイミングで他ユーザーと同じレコードをロックしようとして、両方ロック待ちになる
4. つまり今counter_cacheはlikeの作成と、likeのカウントが同トランザクション内にあるからデッドロックが起こる危険性がある


ということなのでとりあえず、counter_cultureを導入する

`Gemfile`

```
gem 'counter_culture'
```
```
bundle
```

そしてジェネレータでカウント用のカラムを作成する
今回は、postsテーブルにlikeのカウントを保持したいので下記の様にした。

```
rails g counter_culture posts likes_count
```

すると以下の様なマイグレーションが出来る

```
add_column :posts, :likes_count, :integer, null: false, default: 0
```

NOT NULL制約と、デフォルト値は必須らしい。※作成された段階で書いてある

その後、likeモデルに設定の記述をする。

`like.rb`

```
counter_culture :post
```

以上で設定は終了。
これでポストに対するlikeのカウントをが最新で保たれるようになる。

後は普通に

```
post.likes_count
```
みたいな感じで使用すればOK



■参考資料

[Rails向け高機能カウンタキャッシュ gem ‘counter_culture’ README（翻訳）](https://techracho.bpsinc.jp/hachi8833/2017_08_03/43698)
[関連レコード数の集計（カウンターキャッシュ）](https://qiita.com/kanekomasanori@github/items/8155dff193e961828d02)
[デッドロックについて](https://oss-db.jp/dojo/dojo_12)


