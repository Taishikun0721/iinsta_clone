class Post < ApplicationRecord
  belongs_to :user

  # Not Null制約を付けたら必須のバリデーションはつけるべきと考えたので付けた。
  validates :images, presence: true
  validates :body, presence: true, length: { maximum: 100 }

  # 複数枚画像を投稿する時は、mount_uplodersと言う風にsを付けて複数形にする。こうする事で、配列で格納できる様になる。
  # 最初sを飛ばしていて、nullに対してeachメソッドを使う形になっていたのでundifind_methodがでた。sを付けたら空配列に対してeach文なので出ない。
  mount_uploaders :images, PostImageUploader
  # serializeを付けずに投稿するとURLとして認識されてない。
  serialize :images, JSON
  # 並び替えは結構使いそうだから、とりあえずscopeで切り出した。
  scope :recent, -> { order(created_at: :desc) }

  # 遊びメソッド。ダミーusername生成用。名前漏れてたらすみません
  def self.dummy_name_for_sparta(count)
    %w[だいそん hamayooo naok1207 てる かろりーな みけた JUN_Y yu_ki showta0511 なんぶ yukisa2010 takumi Ryo DaiKentaro naoki].sample(up_to_showing_user)
  end
end

# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  body       :text(65535)      not null
#  images     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
