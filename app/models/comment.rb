# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text(65535)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_comments_on_post_id  (post_id)
#  index_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_one :activity, as: :subject, dependent: :destroy
  # ポリモーフィック関連の宣言、like,relationship,commentの3つに同じ宣言を書いている。
  after_create_commit :create_activities
  # after_createとの違いを調べたら、DBにcommitする前にコールバックが発生するのがafter_createで
  # commitされてからコールバックが動くのがafter_create_commit。 そもそもDBにcommitっていう概念があるのが初めて知った
  # コメントやいいねをされてその処理が完了してからactivityが作成される。だから例外が発生したとしても整合性が失われる事はない。
  # bodyが必須のバリデーションと文字列の長さが1000文字までのバリデーション
  validates :body, presence: true, length: { maximum: 1000 }

  def create_activities
    Activity.create(subject: self, user: post.user, action_type: :commented_to_own_post)
    # selfには実際にlikeやコメントしたインスタンスが入って、userにはされた人が入る。
  end
end
