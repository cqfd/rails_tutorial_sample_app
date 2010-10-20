require 'spec_helper'

describe SessionsController do
  render_views

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => 'Sign in')
    end
  end

  describe "POST 'create'" do
    context "failure" do
      before(:each) do
        @session = { :email => "", :password => "" }
      end

      it "should have the right title" do
        post :create, :session => @session
        response.should have_selector('title',
                                      :content => 'Sign in')
      end

      it "should re-render the new page" do
        post :create, :session => @session
        response.should render_template('new')
      end

      it "should display an error message" do
        post :create, :session => @session
        flash.now[:error].should =~ /wrong/i
      end
    end

    context "success" do
      before(:each) do
        @user = Factory(:user)
        @session = { :email => @user.email, :password => @user.password }
      end

      it "should sign the user in" do
        post :create, :session => @session
        controller.current_user.should == @user
        controller.should be_signed_in
      end

      it "should redirect to the user show page" do
        post :create, :session => @session
        # inside of specs, you need to use full named route!
        response.should redirect_to(user_path(@user))
      end
    end
  end

  describe "DELETE 'destroy'" do
    it "should sign out the current user" do
      test_sign_in(Factory(:user))

      delete :destroy

      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end

end
