class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      # Not Null制約を追加バリデーションでpresenceも忘れずにつける。
      t.string :images, null: false
      t.text :body, null: false
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
