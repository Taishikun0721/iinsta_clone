# 09/ユーザー情報更新機能を実装

## ルーティング
まず今回はユーザーのマイページを実装するのでルーティングではnamespaceを切って
そのディレクトリ以下にコントローラーなどを作成していく。

`config/routes.rb`

```
  namespace :mypage do
    resource :account, only: [:edit, :update]
  end
```
今回作成するのはログインしているユーザーのマイページなのでメンバールーティングは必要ない。
そのため、`resource` という単数形を使用してルーティングを設定している。

またnamespaceを切っているのでディレクトリ構成も合わせないといけないので、コントローラーを作成
する際は

```
rails g controller mypage/accoouts
```
のように書いてmypage以下に作成するようにする。

## コントローラー

今回コントローラーは`base_controller`と `accounts_controller`の2つ用意する

`base_contoller`

```
  before_action :require_login
  layout 'mypage'
```

このように`base_controller`を作成する理由はnamespace毎に機能をまとめて設定したいからで
今回はmypageにはログインしているユーザーだけがアクセスできるようにしたい。というのと
 mypage用にマニフェストファイルを新たに設定したかったので上記の様な記述になっている。
 
 `accounts_controller`はシンプルな作りになっていて通常通りにedit・updateアクションが
 ある様な構成になっている。
 
 ## view
 
 view側で気になった機能は`avatar_cache`でCarrierWaveでは`カラム名_cache`を`hidden_field`に設定する事で使用
 することが出来てバリデーションに引っ掛かった場合に、バリデーション前に登録していた画像がそのまま登録された状態で残る。
 これによってまた画像を添付する必要がなくなるため便利になる。
 また`accept`オプションを指定することで画像ファイルだけ添付できる様にするなどの制御が可能になるのは初めて知った。
 こういうオプションはもっと調べて知識として持っておいた方がいいと感じた。
 どちらかと言えばHTMLを勉強した方がviewの機能についてはわかる様になるかなと思ったので、MDNとかを時間がある時に
 読もうかなと思った。
 
 ■参考情報
 [【Rails】CarrierwaveのCache機能を使用し、バリデーション後の画像データを保持する方法](https://techtechmedia.com/cache-carrierwave-rails/)
  