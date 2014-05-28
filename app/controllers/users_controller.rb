class UsersController < ApplicationController


  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  # before_action :signed_in_user_is_logged, only: [:new, :create]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def index
    if params[:search]
      @user = User.search(params[:search]).order("created_at DESC")
      @users = @user.paginate(page: params[:page])
    else
      @users = User.paginate(page: params[:page])
    end
  end

  def edit
  end

  # def destroy
  #   User.find(params[:id]).destroy
  #   flash[:success] = "User deleted."
  #   redirect_to users_url
  # end
  def destroy
    @user = User.find(params[:id])
    if current_user?(@user)
      redirect_to users_path, notice: "You can't destroy yourself."
    else
      @user.destroy
      flash[:success] = "User destroyed."
      redirect_to users_path
    end
  end
  # def destroy
  #   user = User.find(params[:id])
  #   if (current_user? user) && (current_user.admin?)
  #     flash[:error] = "You are not allowed to delete yourself as an admin."
  #   else
  #     user.destroy
  #     flash[:success] = "User destroyed. ID: #{user.id}"
  #   end
  #   redirect_to users_path
  # end
  def update
    if @user.update_attributes(user_params)
     flash[:success] = "Profile updated"
     redirect_to @user
   else
    render 'edit'
    end
  end

def new
  unless signed_in?
    @user = User.new
    @title = "Sign up"
  else
    flash[:info] = "You're already logged in, so you cannot create a new account."
    redirect_to root_path
  end
end
def show
  @user = User.find(params[:id])
  @microposts = @user.microposts.paginate(page: params[:page])
end

def create
    @user = User.new(user_params)    # Not the final implementation!
    if @user.save
      @user.send_email_confirm if @user
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
     :password_confirmation)
  end
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
