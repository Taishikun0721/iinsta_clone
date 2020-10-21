class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]

  def index
    # postモデルにscopeを定義してます。== scope :recent, -> { order(created_at: :desc) }
    @posts = Post.all.includes(:user).recent
    # ダミーテキストじゃなくて、スパルタコースの人がランダムで入るメソッドにしました。しかるべき時がきたら消します。。
    @dummy_names = Post.dummy_name_for_sparta
  end

  def show
    @post = Post.find(params[:id])
    # 完全にダミーコメントです。消します。
    @dummy_comments = [Faker::Games::Pokemon.location, Faker::Games::Pokemon.name]
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to posts_path, notice: '投稿しました'
    else
      flash.now[:danger] = '投稿に失敗しました。'
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, success: '投稿を更新しました。'
    else
      flash.now[:danger] = '投稿の更新に失敗しました。'
      render :edit
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, success: '投稿を削除しました。'
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    # multiple: trueを指定した場合は、配列に値が入ってくるのでストロングパラメーターでは配列でうける。
    params.require(:post).permit(:body, images: [])
  end
end
