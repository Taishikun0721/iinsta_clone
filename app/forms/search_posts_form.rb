class SearchPostsForm
  # ActiveModel::Modelをincludeする事によって、form_withのmodelオプションにインスタンスを渡すことができる様になる。
  # ActiveModel::Attributesをincludeすることで、データの型を指定することができる様になる。実際にモデルを作成していないので
  # Rails側ではどの様な型で持てばいいのか明示的に宣言してあげる必要がある。またAttributesAPIと言うのが実際には動いているらしく
  # 暗黙の型変換を自動的に行ってくれている。
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :body, :string
  attribute :comment_body, :string
  attribute :username_body, :string
  # この記述によって、bodyとcomment_bodyがstring型と言うことが定義された



  def search
    # 各項目を複合で検索する様にした場合、条件分岐がどんどん増えていってしまう様な気がした。そして対策を考えたが、if文を増やす以外にあまり考えられなかったので何かいい方法ないですか？
    post_scope = Post.distinct
    bodys = body.split(' ')
    if body.present?
      post_scope.body_contains(bodys)
    elsif comment_body.present?
      post_scope.comment_body_contain(comment_body)
    elsif username_body.present?
      post_scope.username_contain(username_body)
    else
      post_scope.username_contain(username_body).or((post_scope.comment_body_contain(comment_body))).or(post_scope.body_contain(bodys))
    end
  end
end
