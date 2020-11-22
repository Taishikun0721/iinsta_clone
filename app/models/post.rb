# == Schema Information
#
# Table name: posts
#
#  id          :bigint           not null, primary key
#  body        :text(65535)      not null
#  images      :string(255)      not null
#  likes_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Post < ApplicationRecord
  belongs_to :user
  # postが削除されたら、紐づいているコメントも消えるため, likeも同じ
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  # likeしたuserを取得するlikesテーブルが間に入っているからthroughオプションが必要になる。sourceは別名を使っている時に
  # 必要なオプションで参照先のモデル名を記入する。
  has_many :like_users, through: :likes, source: :user
  # Not Null制約を付けたら必須のバリデーションはつけるべきと考えたので付けた。
  validates :images, presence: true
  validates :body, presence: true, length: { maximum: 100 }
  # 複数枚画像を投稿する時は、mount_uplodersと言う風にsを付けて複数形にする。こうする事で、配列で格納できる様になる。
  # 最初を飛ばしていて、nullに対してeachメソッドを使う形になっていたのでundifind_methodがでた。sを付けたら空配列に対してeach文なので出ない。
  mount_uploaders :images, PostImageUploader

  # serializeを付けずに投稿するとURLとして認識されてない。
  serialize :images, JSON

  scope :body_contain, ->(body) { join_group.where('posts.body like ?', "%#{body}%") }
  scope :username_contain, ->(body) { join_group.where('users.username like ?', "%#{body}%") }
  scope :comment_body_contain, ->(body) { join_group.where('comments.body like ? ', "%#{body}%") }
  # 結合条件を全ての前に付与しないとorで繋ぐことができないので、結合用のscopeを作成
  # inner_joinでは全てのテーブルの完全一致しか取れないのでleft_joinでデータが欠けていても選択範囲に入れる。
  scope :join_group, -> { left_joins(:user).left_joins(:comments) }
  scope :body_contains, ->(bodys) do
    first_scope = body_contain(bodys.first)
    bodys.drop(1).inject(first_scope) { |scope, next_body| scope.or(body_contain(next_body)) }
  end
end
