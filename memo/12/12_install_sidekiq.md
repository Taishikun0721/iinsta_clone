## 課題12 sidekiqでメールの処理を永続化

前回の課題で実装したメーラーの処理を永続化する。
今回の永続化というのは、ActiveJobはデフォルトのジョブ実行は、スレッドプールというところで行われるらしく、これは
再起動した時に、ペンディング状態のジョブを破棄するという性質を持っている。

これを、sidekiqを使用して,キューをredisに積んでいく仕様にすることで、再起動を行ってをジョブが削除されない様にする
というのを今回永続化と呼んでいる。
キューというのはデータ構造の一つで、FIFO(First In First Out)という先入先出しということ。これを非同期実行するので
sidekiqが実行していないjobはキューに溜まっていくこととなる。

`Gemfile`

```
gem 'sidekiq'
gem 'sinatra'
```

もちろん`sidekiq`は導入する。`sinatra`はsidekiqが最初から提供している、ダッシュボードがsinatraで作成されているため
導入する。

次にsidekiqがどうやって、redisにキューを積んでいくかを設定する。
ここでは`redis`の場所を特定するため、redisサーバーのURLとポート番号を指定する。

ここでは、`config`を使って、管理した。

```
Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis.url }
end

Sidekiq.configure_server do |config|
  config.redis = { url: Settings.redis.url }
end

■捕捉
Settings.redis.url = 'redis://localhost:6379'
```

localhost:6379とういうのは自分のPCの6379番ポートに接続してくださいということ
6379はredisのデフォルトのポート番号。

また、設定を`config/sidekiq.yml`にも記載する

```
:concurrency: 25
:queues:
  - default
  - mailer
```

これは、`concurrency`で並行処理するスレッド数を、記載している。
また、どのキューを実行するかを記載している。

デフォルトでは, `default`を見に行くようになっているので、それ以外に見に行って欲しいキューがあればここで指定する。
`set`メソッドを使用しても設定できるらしい。

また、このファイルを`sidekiq`のコマンド実行時に、読み込むオプションが下記となる。

```
bundle exec sidekiq -C sidekiq.yml
```

これで、設定ファイルが読み込まれているので、キューも`default`と `mailer`に分けて管理される。

また話が逸れるが、スレッドというのは、プログラムの命令の単位の事で、この命令を複数同時に実行する事を
マルチスレッドというらしい。調べたけどほとんどわからなかった。

一応[これ](https://qiita.com/k-penguin-sato/items/1326882c400cac8c109b) はやったけど、わからなかった。
また、どこかで繋がるまで軽く覚えておこうと思う。

`perform_later`と `perfrom_now`の違いは非同期実行かどうかで、非同期実行とはその場で実行するのではなく、重い処理などを
メソッドが実行された時と別のタイミングで実行する事をいう。[この例をやったらわかりやすかった](https://qiita.com/jnchito/items/3482a30262874b80a8e4)

ただ重い処理を別タイミングで実行したい場合は、大概、 `perform_later`なのかなと思った。

