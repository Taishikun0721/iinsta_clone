# 08ユーザー詳細画面を作成する。

今回は結構シンプルだった。
普通にusers_controllerにshowアクションを追加して、表示させた。

renderのcollectionオプションを使用してパーシャルの中では

```
thumbnail_post.images.first.url
```

という記述があるので、各投稿の配列に入っている最初の画像がpost詳細へのリンクとなって表示される事になる。

