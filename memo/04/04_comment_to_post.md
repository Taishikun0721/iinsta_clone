# コメント機能を実装する

まずコメントモデルを作成する。コメントは

1. 誰がコメントしたのか？
2. どのpostにコメントしたのか？

の2つを把握したいので**usersテーブル**と**postsテーブル**の中間テーブルとして**comments**テーブルを作成する。


最初にcommnentモデルを作成する。

```
rails g model Comment body:text user:refernces post:references
```

これでモデルとマイグレーションファイルを含む各種ファイルが作成されるので
マイグレーションファイルに制約を追加する。

bodyは必ず必要なので`null: false`のオプションをつける。
userとpostにはreference型を使用しているので外部キー制約が付けられる。
外部キー制約は別名で**参照整合性制約**と呼ばれていて、参照先のテーブルに存在しない値を入れる事を禁止するという事

例を出すとあるpostが3件あり、IDは１～３が降られているとする。そのpostのどれかにコメントする場合に何らかの原因で
４という値がカラムに登録されようとしても外部キー制約がかかっているおかげで登録される事を防ぐことが出来る。


##バリデーション

バリデーションは制約に合わせて作成する。今回は

1. commentに`presence: true`を付ける。（not null制約との整合性確保）
2. UI向上の為に、文字数を表示するバリデーションを書いたこれがないと微妙な文字列の時に分からない。
3. 文字列は1000文字内におさめる様にバリデーションをかける。`length: { maximum: 1000 }`をつける。

## ルーティング

shallowルーティングを使用してルーティングのネストをとる

```
resorces :posts, shallow: true do
  resorces :comments, %i[new create edit update]
end
```

```
shallowなし
post/1/comment/1

shallowあり
comment/1
```
元々post詳細ページの中にコメント機能を実装しているので、そのpostの情報をわざわざURLに出さなくても
いいんじゃ無いかっていう様なイメージ。

## JS.erbについて

`remote: true`のオプションを付けた場合は、デフォルトでjs.erbの様なファイルを探しにいく
今回は、その仕組みをたくさん使っていた。

`_comments.html.slim`
ポストに紐づくコメントの一覧

`_comment.html.slim`
コメント単体。commentモデルのインスタンスを渡してidで判別している。

createアクションの場合、コメント単体をコメント一覧に`prepend`メソッドで1番上に追加する事で実現している。

destroyアクションは、`remove`メソッドでコメント単体指定して削除する

editアクションはidだけ埋め込んだパーシャルを作成してレンダリングする場所(idとかで指定)を作成しておいて
そこに`edit.js.erb`に仕込んだモーダルを表示させる記述から呼び出す。

updateアクションはコメント単体を指定して、`html`メソッドで書き換える。

上記のことはあくまで、JS（jquery）のメソッドの事です。

次に非同期通信についてだが

`html.slim`のファイルだと、作成や更新部分以外のHTMLも全て組み立ててレスポンスボディに
入ってレスポンスとなって戻っていくのでそりゃ非同期通信と比べて遅いよなと思った。
非同期通信の場合は、今回のケースだとcreate,updateなどで使用してるメソッドに渡されているrenderメソッドの部分だけ
HTMLを組み立てて、クライアント側でJSが実行されてそこだけが指定したDOMの部分に入るので同期通信とは読み込んでいる
量が全く違う。非同期通信が早い理由はこんな感じでだと自分は思った。

もちろん開発者ツールとかみても部分的に更新されているのがわかる。


## 自分で勝手に対応や実装を足したところ

1. 未ログイン状態だったらコメントフォームは隠す様にした。コントローラーでもsorceryの`require_login`メソッドを使用
2. コメントの文字数が出る仕組みを導入した。けど今考えたら、残り何文字って言う表示の方がわかりやすかったかなと思った。
3. 今後before_actionが増えていってコントローラーの見通しが悪くなるの可能性が高いなと思った。今回は`set_comment`を使ってプライベートメソッドを呼び出す形に
したけれど、あまり意味はなかったかもしれない。before_actionをどこかに固めたい。