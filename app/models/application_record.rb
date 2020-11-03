class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # コメントインスタンスにも使用したかったのでApplication_Recordに移動
  scope :recent, -> { order(created_at: :desc) }
end
