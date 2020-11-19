## 07_検索機能を実装

今回はpostに対しての検索なの、ルーティングはpostsコントローラーの下に設定する。

`routes.rb`

```
resources :posts do
  get  'search', on: :collection
end
```
このルーティングの設定によって、`posts#search`というエンドポイントが作成される。

`posts#search`に対して、動くコントローラーとアクションは`posts_controller`の`search`アクションなので
そのアクションを作成していく。

`posts_controller`

```
def search
  @posts = @search_form.search.includes(:user).page(params[:page])
end
```
`@search_form`だが今回ヘッダーのアプリ全画面共通部分に検索フォームがあるので、`application_controller`に初期化と値を格納するメソッドを置いている。

```
  def set_search_posts_form
    @search_form = SearchPostsForm.new(search_post_params)
  end

  def search_post_params
    # 普通にrequire(:search_posts_form)で指定してしまうと、application_controllerが呼び出された時点で、エラーになってしまう。
    # SearchPostsFormクラスがまだ読み込まれていないため
    params.fetch(:q, {}).permit(:body)
  end
```
fetchメソッド初めて見た。デフォルト値を入れる様にするメソッドらしく。コメントにも書いているが今回の様に最初から
searchPostFormを指定するとParameterMissingの様なエラーが出るのでそれを防いでいる。

話を戻して次に初期化したクラスに対して、`search`メソッドを呼んでいる。

```
def search
  @posts = @search_form.search.includes(:user).page(params[:page])
end
```

ここでは、SearchPostsFormクラスのインスタンスに対して、searchアクション（コントローラーのsearchではない）
が実行されるのが、下記のsearchメソッド

`forms/searchpostform`
```
def search
  Post.body_contain(body) if body_present?
end
```
forms/SearchPostsForm.rbというファイルを作りそこに`SearchPostsForm`クラスを定義していてここで、form_withで送信したパラメーターを一回受けている。

しかしこのままでは、実際に検索したいPostモデルに対して検索をかけることができない。そのため、一度formで情報を格納したsearchPostsFormクラス内でPostクラスを呼び出して、検索を実行する。
それを行っているのが、上に書いてあるsearchメソッドという事になる。

Postに対して呼び出している`body_contain`はPostクラスのメソッドなのでもmodels/post.rbに定義している。

```
scope :body_contain, ->(body) { where('body like ?', "%#{body}%") }
```

1度パラメータを受けると書いているが、そのためにも下準備が必要でclassを定義した後にまずForm_withのmodelメソッドに渡せる様に
しないといけない。その為に、`ActiveModel::Model`というモジュールをincludeする。
これをincludeする事で、ActiveRecordのデータベースに保存する以外の大体の部分の機能を使用することができるようになる。
今回は使用していないが、バリデーションとかも使える。

あともう1つ`ActiveModel::Attribute`というモジュールをincludeしていてこれはマイグレーションファイルを作成する時などに
普通のモデルならデータ型を定義しているので、あとはRailsが内部でAttributesApiというのを使用して型変換などをよしなにやってくれて
いる。それが今回モデルを定義していないので別でこのモジュールを用意して、定義している。

```
 include ActiveModel::Model
 include ActiveModel::Attributes

 attribute :body, :string
 attribute :comment_body, :string
```

この準備をしていればform_with内で値をうけることができる。

尚、form_withでは、urlオプションを付けて、search_posts_pathをしてあげる。またapplication_controllerで:qと言うprefixを設定したのでここではscope
オプションに:pという引数を渡す。

```
= form_with model: search_form, url: search_posts_path, scope: :q, class: 'form-inline my-2 my-lg-0 mr-auto', method: :get, local: true do |f|
  = f.search_field :body, class: 'form-control mr-sm-2', placeholder: '本文'
  = f.submit 'Search', class: 'btn btn-outline-success my-2 my-sm-0'
```

FormObjectはどちらかというとRailsというよりRubyの要素が強いのかなと思った。
扱っているインスタンスがどのクラスのインスタンスかというところを把握しないと順に追っていけないので自分でクラスとかを作ったり
した遊んでいたことがあったのが結構役に立ったと思いました。

