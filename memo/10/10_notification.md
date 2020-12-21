今回は下記の3つのテーブルにそれぞれデータが作成された場合に通知を作成する。

1. フォローされたとき => relationshipsテーブル
2. いいねされたとき => likesテーブル
3. コメントされたとき => commentsテーブル

なんでそれぞれのモデルにトランザクションコールバックを設定して、createの処理が終わった後に、activityを作成する様にしていた。
これは初めてのパターンだったので知る事ができてよかった。最近Rails特訓コース知らないのとかたくさん出てくるから楽しい笑

今回ポリモーフィック関連を使用して実装するという要件があるので、ポリモーフィック関連で実装する。
今回のケースならそれぞれのテーブルに対してactivitiesテーブルとの中間テーブルを設けても実装は可能だがそれでは通知する対象が増えると中間テーブルがどんどん増え続けてしまうというデメリットがある。
実装してみて感じたが、パーシャルとかの指定はポリモーフィックの場合結構ややこしいなと感じた。

ポリモーフィック関連を使用する際は、下記の様にテーブルを作成する。

```
class create_actibities < ActiveRecoed::Migration[5.2]
  def change
    t.reference :subject, polymorphic: true, null: false
    t.reference :user
    t.integer :action_type, null: false
    t.boolean :read, null: false, default: false
  end
end
```

まずポリモーフィック関連を作成したいので `subject`と関連名を定義して`porimorphic: true`のオプションを付ける。これで`subject_type`と`subject_id`の２つが定義される。
通知はユーザー毎に表示するので`user_id`も定義、あと`action_type`はパーシャルの名前を決めるために設置。

関連付けは以下の様になる。

`models/user.rb`

```
has_many :activities, -> { recent }
```
recentはscopeで定義していたので渡せるかなと思ったが渡せた。下が発行されたSQL
```
 SELECT  `activities`.* FROM `activities` WHERE `activities`.`user_id` = 12 ORDER BY `activities`.`created_at` DESC
```

`models/relationship.rb`

```
has_one :activity, as:subject, dependent: :destroy
```

`models/like.rb`

```
has_one :activity, as: subject, dependent: :destroy
```

`models/comment.rb`

```
has_one :activity, as: subject, dependent: :destroy
```

`models/activity.rb`

```
belongs_to :subject, porimorphic: true
```

となる。

またaction_typeに関しては、`enum`を使用るのでinteger型で定義をした。
これはパーシャルの名前を保管したりするために使用した。
enumはメソッドなどを用意してくれるし、作成するデータが決まっている場合は便利だなと思った。

## ルーティング

```
resources :activities, only: [] do
  redource :read, only: :create
end
```

今回はこの様にreadリソースの作成で既読を表そうかなと思ってやってみた。URLは`activities/activity_id/read`

## コントローラー

ルーティングに合わせて`reads_controller`を作成する。

`controller/reads_controller`

```
def create
  activity = current_user.activities.find(params[:activity_id])
  activity.read! if actibity.unread?
  redirect_to activity.redirect_path
end
```

自分に対するactivityをクリックした時に、未読なら、既読にする。
その後に、`activity.redirect_path`で適切なpathにリダイレクトする。

ちなみにredirect_pathメソッドは下記の様に定義をした。

```
    path = post_path(subject.post, anchor: "comment-#{subject.id}") if commented_to_own_post?
    path = post_path(subject.post) if liked_to_own_post?
    path = user_path(subject.follower) if followed_me?
    path
```
`anchor`オプションは初めて知った。ページ内ジャンプをする様のオプションのことでIDの場所を指定すればその場所を指定してくれる。


通知の一覧はmypage以下で作成するのでnamespaceの中にルーティングを作成する。

```
  namespace :mypage do
    resources :activities, only: :index
  end
```
で作成した。
あとは、reads_controllerの時と同じ様にmypage以下にもパーシャルを作成してあげればOK！

基本的には中間テーブルがあまりにも大量にならない様なら中間テーブルを作成した方がシンプルに書く事はできるかなと思った。
そのあたりは追々勉強できたらいいなと思った。今はいろいろなパターンを抑えていく。
 