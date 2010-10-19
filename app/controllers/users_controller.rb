class UsersController < ApplicationController
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
      redirect_to @user, :notice => "Success!"
    else
      render :new, :notice => "Sorry, something went wrong!"
    end
  end
end
