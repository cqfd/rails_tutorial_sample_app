class SessionsController < ApplicationController

  def new
    @title = 'Sign in'
  end

  def create
    user = User.authenticate(params[:session][:email], 
                             params[:session][:password])

    if user.nil?
      @title = "Sign in"
      flash.now[:error] = "Something went wrong!"
      render :new
    else
      sign_in user
      flash[:success] = "Welcome back!"
      redirect_to session[:return_to] || user
      session.delete(:return_to)
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
