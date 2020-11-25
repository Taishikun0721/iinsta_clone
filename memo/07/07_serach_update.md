# 検索機能をFormObjectを使用して実装 その2

まずシンプルなcommentの検索とusernameの検索について説明していく

`application_controller`

```
params.fetch(:q, {}).permit(:body, :comment, :username)
```
最初にストロングパラメーターを設定して属性をformから送ってくることができる様にする。

その後、ActiveModel::Attributesでも指定してあげてstring型で扱える様にする。
```
  attribute :body, :string
  attribute :comment, :string
  attribute :username, :string
```

searchメソッド内では、それぞれのケースに値があるかどうかでどの検索条件を動かすかを判断する。

`search_posts_form.rb`
```
    scope = Post.distinct
    scope = splited_bodies.map { |splited_body| scope.body_contain(splited_body)}.inject { |result, scp | result.or(scp) } if body.present?
    # 前後の空白を取り除いた配列をmapを使ってワード一つ一つに対して検索をかけていく。その結果をor条件で前ワードで検索した結果と
    # 照らし合わせているinjectメソッドは畳み込み演算のメソッドで前ループまでの結果がresultに入っていく。
    scope = scope.comment_body_contain(comment) if comment.present?
    scope = scope.username_contain(username) if username.present?
    scope
```

ここでは最初にpostsテーブルのコレクションを重複を取り除いてscopeに代入している。
これを最後に返すことで中の条件が何も実行されない時、つまり空で検索ボタンが押された時でもpostsコレクションを返すことができる。
このscopeに対してlikeであいまい検索を実施している

一番ややこしいのは、or条件のあるpostのbodyを検索する条件でまず`splited_bodies`で複数のbodyを整形している※詳細はコメント

```
  def splited_bodies
    # stripメソッドでbodyの前と後ろの空白を取り除いて、空白を区切りにして配列を作成
    #[[:blank:]]+は正規表現みたいで、全く知らなかった。よく使う物に関しては覚えた方が良いかなと思った。
    body.strip.split(/[[:blank:]]+/)
  end
```
そのあとに、mapで単語一つずつの検索結果を取得してそれをinjectメソッドでor条件で畳み込み演算を行う。
結果scopeには全ての条件をor検索にかけた結果が代入される。

usernameとcommentはシンプルで検索したい条件がusersテーブルとcommentsテーブルの中にあるのでjoinsメソッドを使用して
テーブルを結合する。今回は外部キー制約がついているしnullも許可していないので確実に結びつく先があるので内部結合で検索
しても全てのレコードが対象になる。

``` 
  scope :body_contain, ->(word) { where('body like ?', "%#{word}%") }
  scope :username_contain, ->(word) { joins(:user).where('username like ?', "%#{word}%") }
  scope :comment_body_contain, ->(word) { joins(:comments).where('comments.body like ? ', "%#{word}%") }
```


