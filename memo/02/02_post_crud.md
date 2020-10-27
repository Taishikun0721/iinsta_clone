# Rails特訓コース2 PostのCRUDを作成

### PostのCRUDを作成。

注意すべき点は、ストロングパラメーターの `images`のパラメーターの受け方で
form側で`multiple: true`にしているので、複数のパラメーターを受け渡しすることになる。
そのため

```
  def post_params
    # multiple: trueを指定した場合は、配列に値が入ってくるのでストロングパラメーターでは配列でうける。
    params.require(:post).permit(:body, images: [])
  end
```

上記の様にする事で、複数の画像ファイルでも配列の形で受け取る事ができる。
ちなみに複数のファイルを添付する場合はモデルのcarrierwaveの記述を修正する必要がある。

`model/post.rb`

```
  mount_uploaders :images, PostImagesUploader
```
という風に複数形にしないといけない。こうする事で配列で渡すことが出来る。

またStringに配列で格納して、大丈夫なのかと思ったがそこは `serialize`と言う便利なメソッドがあり
stringに配列とかをうまいこと入れさせてくれる。試しにコンソールでみてみると

■serializeなし

```
Post.last.images[1]
=>"[\"any.jpeg\",\"any.png\"]"
文字列になっているエスケープされているし、まあ配列にはなっていないからループとかに入れる事ができない。
```

■serializeあり

```
Post.last.images[1]
=>["any.jpeg", "any.png"]
配列になっているのでループも出来る
```

つまりserializeはよしなに配列とかを入れる事が出来る物と言う解釈をした。

■参考情報

[【Rails入門】checkboxの使い方まとめ](https://www.sejuku.net/blog/27132)
※題材はずれているが配列で受けるところは参考になった。

### Swiperの導入
結構詰まったが、おかげでyarnについて少しわかった。
結局yarnはインストールしたら`node_modules`以下にファイルをまとめてくれるので
必要な物を`application.js`や`application.css`から読み込む必要がある。

2020年7月からver.6にアップデートされてディレクトリ構成も大きく変更されているので
調べて取り込む内に要は上に書いた通りファイル読み込んでいるだけなんだとなった。

Swiperは公式がめちゃわかりやすいのでおすすめ。後ミケタさんの記事もめちゃわかりやすかった。
後、JSはbodyタグの最後で読み込む必要があるらしい。webpackの講座とかやったと気にもそうしたから
なんとなくいけたけどこれは何故なんだろうか。。ググったらなんとなくわかるが腹落ちはしなかった笑

とりあえずJSとCSSを読み込んだ状態になったとして、このままでは動かない。
この後、初期化をしないといけない。

app/javascript以下に`swiper.js`のコードを貼り付けて、初期化する。
ここは公式のままなので割愛します。

■参考情報  
[RailsでSwiperを導入する方法（Swiperは2020年7月にバージョンアップし、従来と設定方法が変わりました！）](https://qiita.com/miketa_webprgr/items/0a3845aeb5da2ed75f82)  
[Swiper公式](https://swiperjs.com/api/)  
[「Swiper」の使い方とオプションを使ってカスタマイズする方法](https://mdstage.com/web/javascript/how-to-use-swiper)

### seedファイルの作成

seedファイルとはDBの初期データを作成する場合に使用する物で`rails db:seed`を実行する事で初期データを作成する事ができる。
今回は、`db/seeds/posts.rb`と`db/seeds/users.rb`を作成してそれを`rewuire`でseeds.rbの中に呼び出して
データを作成する。 
内容はかなりシンプルで、先にusers.rbを実行してユーザーを作成してから紐づくpostsを作成する。
そのため書き方は

`db/seeds.rb`
```
require './db/seeds/users.rb'
require './db/seeds/posts.rb'
```

後、CarrierwaveでURL形式で画像保存を許可する為の属性が用意されていて`remote_カラム名_urls`で保存するとURL形式でも保存できる。

## ダミーデータの追加（Faker・piusum）

Fakserとはダミーデータを簡単に生成してくれるgemの事。色々と種類があっておもしろい笑
今回は、seedファイル作成の際に使用した。

今回は画像データも必要なのでダミー画像作成のサイトを使用した。
今回使用したのは[PlaceIMG](https://placeimg.com/)と[Picsum](https://picsum.photos/)で二つとも使用方法は同じで画像のURLをたたくとジャンル毎に画像を作成してくれる。

■参考情報
[Faker公式](https://github.com/faker-ruby/faker)

## 詰まったとところ

ストロングパラメーターのデータ形式については、色々と復習した。
