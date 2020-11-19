class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # コメントインスタンスにも使用したかったのでApplication_Recordに移動
  # 引数を渡さない場合、全userが降順に並べ替えられるだけにして、引数を渡した場合は、limitが付与される
  scope :recent, lambda { |count = nil|
    count.present? ? order(created_at: :desc).limit(count) : order(created_at: :desc)
  }
end
