# == Schema Information
#
# Table name: relationships
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  followed_id :bigint           not null
#  follower_id :bigint           not null
#
# Indexes
#
#  index_relationships_on_followed_id                  (followed_id)
#  index_relationships_on_follower_id                  (follower_id)
#  index_relationships_on_follower_id_and_followed_id  (follower_id,followed_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (followed_id => users.id)
#  fk_rails_...  (follower_id => users.id)
#
class Relationship < ApplicationRecord
  # 前回と同じだが、別名は自由につけられるが、参照先のテーブルを指定しないといけない
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
  has_one :activity, as: :subject, dependent: :destroy
  # ポリモーフィック関連の宣言、like,relationship,commentの3つに同じ宣言を書いている。

  after_create_commit :create_activities

  # 外部キーなので、必須項目
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  # scopeを使用して、適用範囲をテーブル全体から狭める
  validates :follower_id, uniqueness: { scope: :followed_id }

  def create_activities
    Activity.create(subject: self, user: followed, action_type: :followed_me)
    # ここだけfollowされた人の関連名で指定するのでfollowedで指定する
  end
end
