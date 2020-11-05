# == Schema Information
#
# Table name: users
#
#  id               :bigint           not null, primary key
#  crypted_password :string(255)
#  email            :string(255)      not null
#  salt             :string(255)
#  username         :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  authenticates_with_sorcery!
  # 紐づいているユーザーが削除された場合、紐づいているpostも自動的に全て削除する。commentも同じ likeも同じ
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  # likeされたpostを取得するlikesテーブルが間に入っているからthroughオプションが必要になる。sourceは別名を使っている時に
  # 必要なオプションで参照先のモデル名を記入する。
  has_many :like_posts, through: :likes, source: :post

  validates :email, presence: true, uniqueness: true
  # new_record?は新規登録の場合にバリデーションが作動する。changes[:crypted_password]は更新の時に作動する。
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { :new_record? || changes[:crypted_password] }
  validates :username, presence: true


  # 引数にpostオブジェクトを渡して、左辺のuser.idと比較して同じなら編集と削除のアイコンを表示。
  def own?(object)
    id == object.user_id
  end

  def like(post)
    like_posts << post
    post.reload
    # counter_cultureを入れたのでDBの引き直しが必要になってしまった。SQLが余分に発生しているのであまり良く無い仕様な気がするが、いいねの数が無いと違和感があるので残しておく
    # このあたりのメソッド知らなかったからconsoleで叩いて勉強になった。
    # https://api.rubyonrails.org/ これめちゃよかったです
  end

  def unlike(post)
    like_posts.destroy(post)
    post.reload
  end

  def like?(post)
    # like_postsでcurrent_userがlikeしたpostの一覧が取れてその中に、今回likeした物が含まれているかどうか判定している。
    like_posts.include?(post)
  end
end
