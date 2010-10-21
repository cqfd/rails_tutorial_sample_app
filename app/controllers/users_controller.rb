class UsersController < ApplicationController
  before_filter :authenticate, :only => [ :index, :edit, :update, :destroy ]
  before_filter :correct_user, :only => [ :edit, :update ]
  before_filter :admin_user, :only => [ :destroy ]

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      @title = 'Sign up'
      flash.now[:error] = "Sorry, something went wrong!"
      render :new
    end
  end

  def edit
    @title = "Edit user"
    @user = User.find(params[:id])
  end

  def update
    @user = User.find_by_id(params[:id])

    if @user.update_attributes(params[:user])
      flash[:success] = "You updated your profile successfully!"
      redirect_to @user
    else
      @title = "Edit user"
      flash.now[:error] = "Something went wrong!"
      render :edit # calls to render don't excecute the controller action!
    end
  end

  def destroy
    user_to_destroy = User.find(params[:id])

    if user_to_destroy == current_user
      flash[:error] = "You can't destroy your own admin account!"
    else
      flash[:success] = "User destroyed."
      user_to_destroy.destroy
    end

    redirect_to users_path
  end

  private
    def authenticate
      deny_access unless signed_in?
    end

    def correct_user
      redirect_to root_path unless current_user?(User.find(params[:id]))
    end

    def admin_user
      redirect_to root_path unless current_user.admin?
    end
end
