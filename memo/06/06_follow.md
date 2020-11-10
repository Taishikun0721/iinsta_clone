# follow機能を実装する

follow機能を実装するのは、結構ややこしかった。
なぜなら、シンプルな`has_many ~~~` の様な形ではなく、フッローするのもユーザー、フォローされるのもユーザーなのでusersテーブルからusersテーブルに対してアソシエーションを組む様な形になる。

今回は、relationshipテーブルと言う中間テーブルを利用して、ユーザー同士を結びつける様にする。

まずusersテーブル同士を結び付ける、中間テーブルリレーションシップテーブルを作成する

```
rails g model relationship follow:references followed:references
```

でモデルとマイグレーションファイルが出来る。
今回、usersテーブルに別名を付けて、２つの別テーブルがある様に振舞わせるので外部キーは`follower_id`と`followed_id`の2つにする。またこのままでは外部キーの名前が命名規則からはずれているので、後ほどアソシエーションを設定する際にテーブル名をfollowerとfollowedと呼ばせるような設定を行う。

次は、マイグレーションファイルに制約を加えていく。

付け加える制約は
1. `followed_id`と`follower_id`の複合ユニークキーを設定
2. 外部キーにNOT NULL制約を付け足す

の2つ。

次にモデルアソシエーションを設定していく。

`relationshipテーブル`

```
belongs_to :follower, class_name :User
belongs_to :followed, class_name :User
```

relationshipsテーブルは中間テーブルなのでこのように外部キーを2つもつ。外部キー名を`follower_id`, `followed_id`の2つで設定したので、ここでは`follower`と`followed`という名前でアソシエーションを定義する必要がある。
ただしそのまま定義してしまうと、実際には存在しないfollowersテーブルみたいなのを探しに行ってしまうので`class_name`オプションで`User`と付ける事でusersテーブルを探しに行ってくれる。

これでrelationshipsテーブルのアソシエーションは完了。

次は、usersテーブルのアソシエーションを設定していく。

ここからが難しいのだが、先ほどrelationshipsテーブルでは、`follower`と`followed`という関連を定義したので、それぞれのテーブルから、関連を定義しないといけない。ここでは`active_relationship`と`passive_relationship`という2つのテーブルを定義する。

まずfollowする側から見たアソシエーションが

```
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
```

この関連が使用される時のイメージは
`follower` が `active_relationship` を通して `followed`にアクセスして`follower_id`で絞ったコレクションを持っていくのを`following`と定義する。(`follower_id`で絞ったら、自分がフォローしている人のコレクションが手に入る)

次は逆でfollowされる側から見たアソシエーションで

```
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
```
この関連からイメージされるのは、
`followed`が`passive_relationship`を通って、'followed_id'で絞ったコレクションを持っていくのを`followers`と定義する。(`followed_id`で絞ったら、自分をフォローしている人のコレクションが手に入る。)


この様に、1つのテーブルに名前を付けて、関連を複数定義できるのはとても面白いなと思った。

次にバリデーションだが

```
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id }
```

NOT NULL制約との整合性のために`presence: true`を付与
scopeは前回も書いたがfollower_idがテーブル全体のuniqueキーにならない様に設定している。


`follow`, `unfollow`, `following?` メソッドを実装したがこれはlikeの時と全く一緒の考え方だったのでまとめは割愛

あとは、ユーザー一覧がめんのページネーションも非同期で実装した。非同期処理については色々とチャレンジしたので特訓コース通してかなり慣れてきたなと感じている。

また今回の課題で`recent`と言うメソッドを定義するが、これが以前から勝手に定義していたので汎用的に使用できる様に修正した。

```
  scope :recent, -> (count = nil) do
    return order(created_at: :desc) unless count
    order(created_at: :desc).limit(count)
  end
```

内容としては引数を渡した場合は、`limit`にその数字を入れて絞ることができる。
引数を渡さなかった場合は、普通のorderメソッドだけが走る。と言う様にしている。
