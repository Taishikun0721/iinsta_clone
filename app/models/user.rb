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

  # Relationshipモデルで、1つしかないusersテーブルにfollowerとfollowedと2つ別名を付けているので usersテーブル側からみてもRelationshipsテーブルに双方向からみて2つ別名をつける必要がある。
  # active_relationshipテーブルはfollower_idを外部キーにしてfollowingメソッドで自分がフォローしている人の一覧を取得する。
  # sourceは参照先のテーブルを指定するオプション。つまりfollowerとfollowedの中間テーブルにactive_relationship(foreign_key: follower_idなのでフォローされてる人が絞れる) 様なテーブル構成
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  # passive_relationshipテーブルは、followed_idを外部キーにしてfollowersメソッドで自分をフォローしている人の一覧を取得する。
  # さっきと逆でfollowerとfollowedの中間テーブルにpassive_relationship(foreign_key: followed_idなのでフォローしてる人が絞れる) 様なテーブル構成
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower
  # ここはめちゃ難しかったのでd、だいそんさんのサンプルのconsoleで動かしてみたり、定義の名前を入れ替えてみてどんなエラーが出るかなど結構いじった。
  # 結果、usersテーブルとrelationshipテーブルしか無いが、名前を変更する事で、

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

  # likeの時と全く一緒の理屈！followingはフォローしている人のコレクションだから、追加すれば良い
  def follow(other_user)
    following << other_user
  end
  # 逆にアンフォローしたければ、destroyの引数にアンフォローしたユーザーを渡せば良い
  def unfollow(other_user)
    following.destroy(other_user)
  end
  # コレクションに存在していればtrueしてなければfalse
  def following?(other_user)
    following.include?(other_user)
  end

  def feed
    # idの前にはselfが省略されている。following_idsはhas_manyで関連付けされた時に追加されるメソッドで、フォローしている人のリストを返す。
    # 今回はそれに自分のIDを追加して、whereで検索をかけている。そのためこれで自分とフォローしているユーザーのコレクションが返る。
    Post.where(user_id: following_ids << id)
  end
end
