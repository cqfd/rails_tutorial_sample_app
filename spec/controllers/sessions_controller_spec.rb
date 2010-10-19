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
  end

end
