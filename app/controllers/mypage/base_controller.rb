class Mypage::BaseController < ApplicationController
  # かろりーなさんのレビューの時にもダイソンさんが言っていたが、mypageなどのnamespaceを切ったところにはbasecontrollerを置いて
  # そのディレクトリ以下に追加していくコントローラーをまとめるapplication_controller::Baseの様な役割になる。
  before_action :require_login
  layout 'mypage'
end
