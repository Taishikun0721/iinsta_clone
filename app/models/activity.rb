# == Schema Information
#
# Table name: activities
#
#  id           :bigint           not null, primary key
#  action_type  :integer          not null
#  read         :boolean          default(FALSE), not null
#  subject_type :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subject_id   :bigint
#  user_id      :bigint           not null
#
# Indexes
#
#  index_activities_on_subject_type_and_subject_id  (subject_type,subject_id)
#  index_activities_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Activity < ApplicationRecord
  include Rails.application.routes.url_helpers
  # プレフィックスをモデルで使用したいのでmoduleを使用する
  belongs_to :subject, polymorphic: true
  belongs_to :user

  enum action_type: { commented_to_own_post: 0, liked_to_own_post: 1, followed_me: 2 }
  # パーシャルを呼び出すのに使っているのとリダイレクトをさせる為に作成している。通知の種類が増えるたびにパーシャルが増えるので 追加していける。
  # subjectでそれぞれのモデルを特定できるので、ダックタイピングでもリダイレクト先を各モデルに定義する事はできるかなと思った。
  # けどモデル内で更新とか削除とかの通知で場合分けする必要が出てきた場合に結局各モデル内で条件分岐が発生するので、action_typeはあった方が良い。
  # 結果、最初になくてもいいんじゃないかと思ったけどaction_typeは必要という結論になった。
  enum read: { unread: false, read: true }
  # 既読判定を行うenumを定義、enumって結構便利なメソッドがたくさん準備されているのを知った。

  def redirect_path
    path = post_path(subject.post, anchor: "comment-#{subject.id}") if commented_to_own_post?
    path = post_path(subject.post) if liked_to_own_post?
    path = user_path(subject.follower) if followed_me?
    path
  end
  # enumで追加されるメソッドで?付きがあったのでif文で書いてみました！
  # returnを全行に書くか迷ったけどRubyは普通return書かない(早期return以外)ってチェリー本に書いていた気がするからこっちにした。
end
