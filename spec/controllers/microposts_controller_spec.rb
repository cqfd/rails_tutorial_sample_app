require 'spec_helper'

describe MicropostsController do
  render_views

  describe "access control" do
    it "denies access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "denies access to 'destroy'" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'create'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    context "failure" do
      before(:each) do
        @attr = { :content => "" }
      end

      it "does not create a micropost" do
        expect do
          post :create, :micropost => @attr
        end.to_not change(Micropost, :count)
      end

      it "re-renders the home page" do
        post :create, :micropost => @attr
        response.should render_template('pages/home')
      end
    end

    context "success" do
      before(:each) do
        @attr = { :content => "Lorem ipsum dolor" }
      end

      it "creates a micropost" do
        expect do
          post :create, :micropost => @attr
        end.to change(Micropost, :count).by(1)
      end

      it "redirects to the root path" do
        post :create, :micropost => @attr
        response.should redirect_to(root_path)
      end

      it "sets the success flash" do
        post :create, :micropost => @attr
        flash[:success].should =~ /micropost created/i
      end
    end
  end
end
