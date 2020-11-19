class SearchPostsForm
  # ActiveModel::Modelをincludeする事によって、form_withのmodelオプションにインスタンスを渡すことができる様になる。
  # ActiveModel::Attributesをincludeすることで、データの型を指定することができる様になる。実際にモデルを作成していないので
  # Rails側ではどの様な型で持てばいいのか明示的に宣言してあげる必要がある。またAttributesAPIと言うのが実際には動いているらしく
  # 暗黙の型変換を自動的に行ってくれている。
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :body, :string
  attribute :comment_body, :string
  # この記述によって、bodyとcomment_bodyがstring型と言うことが定義された

  def search
    # 今回は重複があっても問題ないので、Distinctは使用しなくていいかなと思って使用しませんでした
    # あくまでSearchPostsFormクラスは、フォームで一時的に値を格納する受け皿になっているだけなので、最終的にはPostモデルに対して検索をかける
    # Postクラスの中を検索して、結果を返してあげないといけない。
    # body_containはPostクラスのメソッドなのでmodels/post.rbに記載あり
    scope = Post.distinct
    scope = scope.body_contain(body) if body.present?
    scope
  end
end
