class Post < ApplicationRecord
  belongs_to :user

  # Not Null制約を付けたら必須のバリデーションはつけるべき。
  validates :images, presence: true
  validates :body, presence: true, length: { maximum: 100 }
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
