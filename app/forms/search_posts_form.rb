class SearchPostsForm
  # ActiveModel::Modelをincludeする事によって、form_withのmodelオプションにインスタンスを渡すことができる様になる。
  # ActiveModel::Attributesをincludeすることで、データの型を指定することができる様になる。実際にモデルを作成していないので
  # Rails側ではどの様な型で持てばいいのか明示的に宣言してあげる必要がある。またAttributesAPIと言うのが実際には動いているらしく
  # 暗黙の型変換を自動的に行ってくれている。
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :body, :string
  attribute :comment, :string
  attribute :username, :string
  # この記述によって、bodyとcomment_bodyがstring型と言うことが定義された

  def search
    # 各項目を複合で検索する様にした場合、条件分岐がどんどん増えていってしまう様な気がした。そして対策を考えたが、if文を増やす以外にあまり考えられなかったので何かいい方法ないですか？
    scope = Post.distinct
    scope = splited_bodies.map { |splited_body| scope.body_contain(splited_body)}.inject { |result, scp | result.or(scp) } if body.present?
    # 前後の空白を取り除いた配列をmapを使ってワード一つ一つに対して検索をかけていく。その結果をor条件で前ワードで検索した結果と
    # 照らし合わせているinjectメソッドは畳み込み演算のメソッドで前ループまでの結果がresultに入っていく。
    scope = scope.comment_body_contain(comment) if comment.present?
    scope = scope.username_contain(username) if username.present?
    scope
  end

  private

  def splited_bodies
    # bodyの前と後ろの空白を取り除いて、空白を区切りにして配列を作成
    #[[:blank:]]+は正規表現みたいで、全く知らなかった。よく使う物に関しては覚えた方が良いかなと思った。
    body.strip.split(/[[:blank:]]+/)
  end
end
