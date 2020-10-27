# kaminariを使用してページネーションを実施する

## controller側（同期処理）

まずgemをインストールする。

`Gemfile`

```
gem 'kaminari'
```

`ターミナル`

```
bundle install
```

ここからまず同期処理で処理するにはコントローラーにこう記述する

```
def index
  @posts = Post.page(params[:page]).per(3)
end
```
上記の様にする事で1枚のページに表示する件数を指定できる。
ちなみに`per(3)`の部分は、設定ファイルに記載することで省略する事も出来る。

設定ファイルの作成方法は

```
rails g kaminari:config
```
と打つとviews/kaminariファイルいかに設定ファイルが出来るのでその中身をいじる

```
Kaminari.configure do |config|
  # config.default_per_page = 25 # 1ページ辺りの項目数
  # config.max_per_page = nil    # 1ページ辺りの最大数
  # config.window = 4            # ex 値が2の場合 .. 2 3 (4) 5 6 ..
  # config.outer_window = 0      # ex 値が2の場合 .. (4) .. 99 100
  # config.left = 0              # ...になったときの左側の表示数
  # config.right = 0             # ...になったときの右側の表示数
  # config.page_method_name = :page # メソッド名
  # config.param_name = :page    # ページネーションのパラメーターの名前
end
```

ここまででコントローラー側(同期処理)の実装は終了。

## view側（同期処理）

view側は超簡単で1行を書くのみ表示させたい場所に

```
= paginate @posts
```
でOK

また

```
rails g kaminari:views bootstrap4
```

でbootstrapに対応したviewが簡単にできる！便利！


## 非同期処理の流れ

次は非同期処理で実装する方法を説明していく。
流れを簡単に説明すると

1. kaminariの導入とcontorollerの変数を定義するところまでは、同じ。
2. ただし非同期処理で実装するのでhtml.erbではなくjs.erbで実装する。

## controller側（非同期処理）

```
def index
  @posts = Post.page(params[:page]).include(:user)  <= perはconfigに定義
end
```

`index.js.erb`(レスポンス用のview)

```
var postsPaginate = document.querySelector('#posts');
#ここは上書きされるのでvarじゃないとエラーがでた
postsPaginate.innerHTML = "<%= j render(@posts) %><%= j paginate @posts, remote: true %>  "

var mySwiper = new Swiper ('.swiper-container', {
    loop: true,
    pagination: {
        el: '.swiper-pagination',
    },
    autoplay: {
        delay: 3000,
    },
})
//クライアント側に上のJSが返却されて実行される。その際swiperの初期化コードはすでに読み込まれているから再定義してあげないと動かない？？
//ここはもっと調べたい

```

`index.html.erb`

```
#posts.col-md-8.col-12
  = render @posts
  = paginate @posts, remote: true
```

このidのpostsを非同期処理で置き換えている。
swiperのところはもっといい書き方が絶対あると思うので、調べてリファクタリングしたい


## 参考資料
[kaminari徹底入門](https://qiita.com/nysalor/items/77b9d6bc5baa41ea01f3)  
[【rails】kaminariを使ってページネーションを作る](https://qiita.com/you8/items/df68aaee3010e282d1ae)  
[Kaminariの使い方 まとめ](http://nekorails.hatenablog.com/entry/2018/10/15/005146)  
[kaminariを使ってajax通信でページ送りを実装しました](http://yutaszk23.hatenadiary.jp/entry/2014/03/08/211430)

