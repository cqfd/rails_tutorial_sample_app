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
      cookies[:user_id] = user.id
      flash[:success] = "Welcome back!"
      redirect_to user
    end
  end

  def destroy
    
  end

end
