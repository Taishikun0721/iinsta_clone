# == Schema Information
#
# Table name: likes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  post_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_likes_on_post_id              (post_id)
#  index_likes_on_user_id              (user_id)
#  index_likes_on_user_id_and_post_id  (user_id,post_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#  fk_rails_...  (user_id => users.id)
#
class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_one :activity, as: :subject, dependent: :destroy
  # subjectという名前で関連づけを行う。ちなみに他の二つもポリモーフィックだから同じ
  # 関連名は全て、subjectだけどactivityがラッパーになっているのでダックタイピングが使える。
  # counter_cultureの記述。post_countカラムのカウントが最新に保たれるらしい。深くは理解できていない。
  counter_culture :post
  after_create_commit :create_activities
  # user_idが一意になる様にuniquenessを設定している。scopeを指定しないとテーブル全体で一意の値になってしまうため
  # post_idを指定してあげる事で、各postの中で一意な値になる
  validates :user_id, uniqueness: { scope: :post_id }

  def create_activities
    Activity.create(subject: self, user: post.user, action_type: :liked_to_own_post)
    # selfには実際にlikeやコメントしたインスタンスが入って、userにはされた人が入る。like.post.userなのでlikeされたpostの投稿者
  end
end

