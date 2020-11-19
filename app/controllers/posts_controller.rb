class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]
  # 指定したメソッドについてはログインを必須にしている。
  before_action :require_login, only: [:new, :create, :edit, :update, :destroy, :search]
  # ログイン前は検索機能は使えない様になっていたので、コントローラー側でも制御をかけました。view側も非表示にしています。

  def index
    # recentメソッドは元々使用していた部分があったので、少し拡張して、引数なしでもいい様にした。引数なしの場合は普通に降順にするだけです。
    # feedメソッドは、フォローしているリストに自分をするメソッド。つまり、自分とフォローしている人だけを表示できることを示す
    @posts = if current_user
               current_user.feed.includes(:user).page(params[:page]).recent
             else
               Post.all.includes(:user).page(params[:page]).recent
             end
    @users = User.recent(5)
    @page = params[:page]
  end

  def show
    @post = Post.find(params[:id])
    @comment = Comment.new
    # N+1問題解決のためにこの様な書き方をしている。テーブルをまたいで取得しにいく場合はまず発生するので忘れずに書く
    @comments = @post.comments.includes(:user).recent
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

  def edit; end

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

  def search
    # usernameを中で呼び出す限りincludesは必要(テーブルを跨いでいるため。)
    # @search_formでインスタンスを作成して中に入力したパラメーターを入れている。searchメソッドはSearchPostFormクラスのメソッドなのでFormObject内に記述あり
    @posts = @search_form.search.includes(:user).page(params[:page])
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
