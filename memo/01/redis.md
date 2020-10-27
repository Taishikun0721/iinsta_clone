# Redisについて

### key_value型のDB
JSONとかRubyのハッシュの様な形でデータを保持している。

### インメモリ型のDB
RedisはインメモリDBでメモリ上で動作する。PCのメモリは、電源を落とすと消えてしまう
これはネット記事では「揮発性がある」と表現されている。
ただ永続化の設定もできるらしい。

### なぜRedisを使うのか
railsのデフォルトでは**cookiestore**という仕組みが使われている。
これは、session情報をcookie（クライアント側）にいれて保持して必要な時にサーバーに送信する仕組みでなので暗号化されているものの、session情報が盗まれた場合の危険性が高い。
ただしサーバー側では復号化してsession情報を取り出すだけでDBへのアクセスがないので処理は早い。

これは最近ではあまりない方式らしい。

そこで登場するのが**Redis**。
サーバー側でsession_idを作成して、実際のsession情報とsession_idをセットでredisに保存する。
クライアント側のcookieにも実際のsession情報ではなくsession_idが保存される。

リクエストの際にはクライアント側でsession_idをサーバ側に投げて、サーバーがredisにアクセスして実際のsession情報を取り出す。
つまりsession_idしかやり取りしていないので、盗まれたとしても問題ない。
ただサーバー側からDB(redis)にアクセスしているので、早さはcookiestoreに劣る。（ただ遅いわけではなく速い分類）

■参考資料

[Railsのセッション管理には何が最適か](https://qiita.com/shota_matsukawa_ga/items/a21c5cf49a1de6c9561a)  
[Railsセキュリティガイド](https://railsguides.jp/security.html#%E3%82%BB%E3%83%83%E3%82%B7%E3%83%A7%E3%83%B3%E3%82%B9%E3%83%88%E3%83%AC%E3%83%BC%E3%82%B8)  
[セッションとクッキーの謎](https://www.youtube.com/watch?v=EgUgmYLuLYE)

