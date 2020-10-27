# Rails特訓コース1　初期構築&ログイン機能を実装


### Rubyのバージョンを2.6.4とする。

```
rbenv local 2.6.4
```
これでディレクトリ内のrubyのバージョンが2.6.4になる

インストールできていなかったら[ここ](https://qiita.com/Kodak_tmo/items/73147ed4f0eec54d6e94)をみる

### `rails new`をする時にturbolinkとcoffeescriptをオフにする。

```
rails new instaclone -d mysql --skip-coffee --skip-turbolinks
```
これでturbolinksとcoffeescriptはオフになる、

ちなみにturbolinksは`a`タグがクリックされると発火して画面遷移をAjax化するものである。
基本的には、GETリクエストに対応している。
ただしブラウザの遷移が発生しないことも多いらしく、挙動が不安定らしい。
自分は使った事はない。

coffeescriptはjavascriptをRubylikeに書くことができるAltJSというもので最近はあまり使われていなものらしい。
最近流行ってるTypescriptも同じくAltjsで同じ分類。Reac&Typescriptは相性がいいみたい。興味ある。

■参考情報

現場Rails第8章

## 機能関連

`pry-byebug`
ソースコードに`binding.pry`というブレイクポイントを設置できる様になる。

`pry-rails`
デバッグ中に`next`で次の処理に進める様になる。

`better_errors`
エラー画面がすごく見やすくなるgem。個人的に好き

`binding_of_caller`
ブラウザ上のエラー画面でコンソールが使用できる。

`rails-i18n`
国際化対応。バリデーションのエラーメッセージ などは日本語化してくれる。
自分でカスタマイズしたい場合は、`config/locales`以下にファイルを作成して内容を記述する。

■導入方法

`config/application.rb`

```
    # Railsのタイムゾーンを指定する。
    # またアプリのデフォルトの言語を日本語にする。
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
　　 # デフォルトの言語を日本語にする
    config.i18n.default_locale = :ja 
```

上の2行はタイムゾーンを変更していて、最後の行で日本語化対応を設定している。
セットみたいな物と考えて良さそう。


`rubocop`

RubyのLintチェックツール。
`rubocop`コマンドで構文チェックをしてくれて`rubocop -a` で自動的に決められたルールにそって修正してくれる。

またルールだが、`.rubocop.yml`というファイルに記載してプロジェクト毎に独自のルールを設定していく。
ただしチェックが超厳しいので、`rubocop_todo.yml`というファイルを作成してそこに一時的に無視するルールを記載していくことでrubocopの監視から逃れられる。

そして`rubocop_todo.yml`を減らしていき最終的に`rubocop_todo.yml`が全て空になることがベスト

■参考情報

[RuboCopをRailsオプションやLintオプションで使ってみよう - Sider Blog](https://blog-ja.sideci.com/entry/2015/03/12/160441)
[RuboCopの設定アレコレ - Qiita](https://qiita.com/necojackarc/items/8bc16092bbc69f17a16d)

`sorcery`

認証用のメソッド等を用意してくれるgem
インストールするとuserモデルが自動的に作成されて、カラム名等も準備される
後は、用意されているメソッドを使用するだけ。
現場railsで認証系を作ったので、だいたいこんな感じかなという感じで行けた


■参考情報

[Sorcery/sorcery: Magical Authentication - GitHub](https://github.com/Sorcery/sorcery)
[Rails+Sorceryで認証処理を実装する | SG Labs](https://www.sglabs.jp/rails-sorcery/)

`yarn`

node.jsのパッケージマネージャーの事。ちなみにnode.jsとはサーバーサイドで動くJSの事で
もともとJSはフロントエンド（ブラウザ）でしか動作しなかった。
パッケージマネージャーというと、Rubyでいう`bundler`みたいなもので様々なツール？のバージョンを
管理してくれるもの

メリットとしては
1. npmよりはやい
2. packege.jsonをnpmと共有できる

などなどあるらしい。

webpackやったら概要はわかると思うので、また分かったらまとめようと思う。

ちなみにやろうと思っているwebpackの講座は[これ](https://www.udemy.com/course-dashboard-redirect/?course_id=2073632)


`bootstrap-material-design`

一番苦戦した。yarnがパッケージマネージャーというのは知っていたが、Railsの中ではどの様にして取り込むのかなどが全く分からなかった。`node_modules`という単語を一度`webpack`をいじっていた時に見たことがあるので、これがきっかけでやり直そうと思った。
依存関係があり、`jquery`と`popper.js`が必要。このあたりは普通のBootstrapと一緒。
そこまではわかったがyarmで入れるのかgemでいれるのかどちらが良いか分からなかった。
最終的にはだいそんさんの真似をして、gemで入れた。
ちなみにyarnでも入れてみたがわからなかったので一旦とばした、yarn.lockにも記載されている。
ここは勉強不足なので、勉強する。

`redis`

長くなったので別記事でまとめた

`slim`  

Rubyで作られたHTMLのテンプレートエンジンでタグを短く書くとができる。
なんとなくemmetと似ているので、使いやすいと思った。
また`html2slim`というslimへの変換用のgemが存在する



■参考情報

現場rails3章  
[Slim入門をして書き方を練習をしました](https://qiita.com/pugiemonn/items/b64171952d958dc4d6be)


`annotate` 

導入することで、モデルにDBのカラム情報をコメントで書き出してくれるgem
バリデーションとか書く時に書き忘れ防止になるから便利だなと感じた。
また、モデル以外にもルーティングなども設定できる。
設定ファイルは`lib/tasks/auto_annote_modules.rake`でここをいじる事で設定ができる

■参考情報

[【Rails】annotateの使い方](https://qiita.com/kou_pg_0131/items/ae6b5f41c18b2872d527)


`git flow`

git flowとはgitのブランチモデルのこと。

使い方ととしては

```
git flow init 
```
で初期化を行う。
その後、色々と聞かれるが基本はエンターでOK。その後確認するとdevelopブランチが作成されている。基本的にdevelopブランチがデフォルトのブランチになって
そこにmergeしていく形となる。基本の作業ブランチはfeatureブランチを切って作業をしてdevelopブランチにプルリクを作成する。
masterブランチはデプロイする時以外は、基本的にmergeしない。
またmasterブランチにmergeする前にもreleaseブランチを切って最終的な調整を行う。ここで確認が取れない場合はmasterにはmergeしない
またmasterブランチから不具合がでた場合は直接hotfixブランチを切り修正。その後develブランチにmergeされる。

現場raisのアウトプットの時も見様見真似でやっていたので、大体できたと思う。
issue番号はつけた方が良いのかは気になる。

■参考情報

[Git-flowって何？](https://qiita.com/KosukeSone/items/514dd24828b485c69a05)

`database.yml`

database.ymlにはデータベース接続に必要な情報usernameやpasswordなどが記載されている。
これをそのままgit管理すると、自分のusernameやpasswordが流出してしまう。

```
mysql -u root -p 
```

で聞かれるパスワードが入っていると思ったらわかりやすい。

この運用方法は色々なパターンがネットに落ちているが
今回採用したのは、`database.yml.example`を作成するパターン。
流れを説明すると

1.`Rails new`した段階で`database.yml`は`.gitignoreに入れてしまう`  
2.代わりにパスワードなどだけ書かれていないファイル`database.yml.example`というファイルを作ってこれをgit管理する。  
3.　`database.yml.example`のおかげでリネームしてユーザー名とパスワードを書き換えるだけで使える。

という感じ。

他にも環境変数を使用するパターンもあったので、また試してみたい。

`schema.rb`

現在のDBのスキーマ情報が反映されている。
テーブル構成、制約やindexなどなど、このファイルはマイグレーションファイル(rails db:migrate後)を作成すると自動で更新されるので自分で修正してはいけない。

`マイグレーションファイル`

マイグレーションファイルとはテーブルの設計図のことで
Rubyからテーブル情報を操作するときに作成するファイルのこと。
このファイルは時系列順に管理されていて、データベースにどの様な変化を加えたかわかる様になっている。
また、勝手に削除してしまうと環境を変えた際に`rails db:migrate``などのコマンドが通らなくなってしまうので勝手に削除などしてはいけない。

考えてみると間違えたマイグレーションファイルをgithubにあげてしまった時などあまり考えたことがなかったので
一度失敗した体でやってみようと思った。

### 復習すべきところなど

1. bootstrapで`btn btn-primary`でボタンを指定したのに、見本と違う色になった。原因調査中
2. ログインフォームがかっこよかったので、自分でもCSSを書いてみようと思った
3. フラッシュメッセージの出し方は勉強になった。
4. 部分テンプレートの使い方が勉強になった。フロントエンドの管理にも興味が出てきた
5. マイグレーションを間違えてGithubにpushしたパターンの修正方法