class CreateLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      # dependent: :destroyで親が消されたら削除する予定なのでnullは許可しない
      t.references :user, foreign_key: true, null: false
      t.references :post, foreign_key: true, null: false

      t.timestamps
    end
    add_index :likes, [:user_id, :post_id], unique: true
  end
end
