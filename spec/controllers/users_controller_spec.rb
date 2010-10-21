require 'spec_helper'

describe UsersController do
  render_views

  describe "GET 'index'" do
    context "non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
      end
    end

    context "signed-in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        Factory(:user, :email => "another@example.com")
        Factory(:user, :email => "another@example.net")

        30.times do
          Factory(:user, :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector('title', :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        User.paginate(:page => 1).each do |user|
          response.should have_selector('li', :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector('div.pagination')
        response.should have_selector('span.disabled', :content => "Previous")
        response.should have_selector('a', :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector('a', :href=>"/users?page=2",
                                           :content => "Next")
      end

      it "should have delete links for admins" do
        @user.toggle!(:admin)
        other_user = User.all.second

        get :index
        response.should have_selector('a', :href => user_path(other_user),
                                           :content => "delete")
      end

      it "should not have delete links for non-admins" do
        other_user = User.all.second
        get :index
        response.should_not have_selector('a', :href => user_path(other_user),
                                           :content => "delete")
      end
    end
  end

  describe "GET 'show'" do
    before(:each) do
      @user = Factory :user
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector('title', :content => @user.name)
    end

    it "should have the user's name" do
      get :show, :id => @user
      response.should have_selector('h1', :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector('h1 > img', :class => 'gravatar')
    end

    it "should have the right URL" do
      get :show, :id => @user
      response.should have_selector('td > a', :content => user_path(@user),
                                              :href => user_path(@user))
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end

    it "should have the right title" do
      get :new
      response.should have_selector('title', :content => 'Sign up')
    end
  end

  describe "POST 'create'" do
    describe "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", :password => "", 
                  :password_confirmation => "" }
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector('title', :content => 'Sign up')
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not create a user" do
        lambda { post :create, :user => @attr }.should_not change(User, :count)
      end
    end

    describe "success" do
      before(:each) do
        @attr = { :name => "Alan O'Donnell", :email => "alan.m.odonnell@gmail.com",
                  :password => "letmein", :password => "letmein" }
      end

      it "should create a user" do
        lambda { post :create, :user => @attr }.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end

      it "should display a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /Welcome to the Sample App/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in @user
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector('title',
                                    :content => 'Edit user')
    end

    it "should have a link to change the gravatar" do
      get :edit, :id => @user
      response.should have_selector('a', :href => "http://gravatar.com/emails",
                                    :content => "change")
    end
  end

  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    context "failure" do
      before(:each) do
        @attr = { :name => "", :email => "", 
                  :password => "", :password_confirmation => "" }
      end

      it "should render the edit page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector('title',
                                      :content => "Edit user")
      end

      it "should display an error notice" do
        put :update, :id => @user, :user => @attr
        flash.now[:error].should == "Something went wrong!"
      end

    end

    context "success" do
      before(:each) do
        @attr = { :name => "New Name", :email => "new_user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should update the user's attributes" do
        put :update, :id => @user, :user => @attr

        user = assigns(:user)

        @user.reload
        
        @user.name.should == user.name
        @user.email.should == user.email
        @user.salt.should == user.salt
        @user.encrypted_password.should == user.encrypted_password
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end
  
  describe "authentication of edit/update actions" do
    before(:each) do
      @user = Factory(:user)
    end

    context "user not signed in" do
      it "should deny access to 'edit' when not signed in" do
        get :edit, :id => @user
        response.should redirect_to signin_path
        flash[:notice].should =~ /sign in/i
      end

      it "should deny access to 'update' when not signed in" do
        put :update, :id => @user, :user => {}
        response.should redirect_to signin_path
        flash[:notice].should =~ /sign in/i
      end
    end

    context "user signed in" do
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in wrong_user
      end
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do
    before(:each) do
      @user = Factory(:user)
    end

    context "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    context "as a non-admin user" do
      it "should protect the action" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    context "as an admin" do
      before(:each) do
        # note that factories bypass attr_accessible!
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in admin
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users index page" do
        delete :destroy, :id => @user
        flash[:success].should =~ /user destroyed/i
        response.should redirect_to(users_path)
      end
    end

    context "as an admin trying to destroy herself" do
      it "should fail" do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in admin

        lambda do
          delete :destroy, :id => admin
        end.should_not change(User, :count)
      end

      it "should redirect to the users index page" do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in admin

        delete :destroy, :id => admin
        flash[:error].should =~ /you can't destroy your own admin account/i
        response.should redirect_to(users_path)
      end
    end
  end
end
