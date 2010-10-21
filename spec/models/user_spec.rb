require 'spec_helper'

describe User do
  let(:attr) { 
    {
      :name => "Example User", 
      :email => "user@example.com",
      :password => "password", 
      :password_confirmation => "password"
    }
  }

  it "should create a new instance given valid attributes" do
    User.create! attr
  end

  it "should require a name" do
    no_name_user = User.new(attr.merge :name => nil)
    no_name_user.should_not be_valid
  end

  it "should require an email" do
    no_email_user = User.new(attr.merge :email => nil)
    no_email_user.should_not be_valid
  end

  it "should reject names that are too long" do
    name = "a" * 51
    long_name_user = User.new(attr.merge :name => name)
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[ user@foo.com THE_USER@foo.bar.org first.last@foo.jp ]
    addresses.each do |address|
      valid_email_user = User.new(attr.merge :email => address)
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[ user@foo,com user_at_foo.org example.user@foo. ]
    addresses.each do |address|
      invalid_email_user = User.new(attr.merge :email => address)
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create! attr
    user_with_duplicate_email = User.new attr
    user_with_duplicate_email.should_not be_valid
  end

  it "shold reject email addresses identical up to case" do
    User.create! attr
    user_with_upcased_email = User.new(attr.merge :email => attr[:email].upcase)
    user_with_upcased_email.should_not be_valid
  end

  describe "passwords" do
    let(:user) { User.new(attr) }

    it "should have a password attribute" do
      user.should respond_to(:password)
    end

    it "should have a password confirmation attribute" do
      user.should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do
    it "should require a password" do
      attr_without_passwords = attr.merge(:password => "", 
                                          :password_confirmation => "")
      User.new(attr_without_passwords).should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(attr.merge :password_confirmation => "invalid").should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 41
      hash = attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @user = User.create! attr
    end

    let(:user) { @user }

    it "should have an encrypted password attribute" do
      user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      user.encrypted_password.should_not be_blank
    end

    it "should have a salt attribute" do
      user.should respond_to(:salt)
    end

    it "should set the salt attribute" do
      user.salt.should_not be_blank
    end

    describe "#has_password?" do
      it "should exist" do
        user.should respond_to(:has_password?)
      end

      it "should return true if the guess matches the password" do
        user.should have_password(attr[:password])
      end

      it "should return false if the guess doesn't match the password" do
        user.should_not have_password('incorrect')
      end
    end

    describe "authenticate class method" do
      it "should exist" do
        User.should respond_to(:authenticate)
      end

      it "should return nil on email/password mismatch" do
        User.authenticate(attr[:email], 'wrong password').should be_nil
      end

      it "should return nil for an email address with no user" do
        User.authenticate("bar@foo.com", attr[:password]).should be_nil
      end

      it "should return the right user if email/password match" do
        User.authenticate(attr[:email], attr[:password]).should == user
      end
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user = User.create!(attr)
    end
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "micropost associations" do
    before(:each) do
      @user = User.create!(attr)
      @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
      @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    it "should have the right associated microposts in the right order" do
      @user.microposts.should == [@mp2, @mp1]
    end

    it "should destroy associated microposts" do
      @user.destroy
      [@mp1, @mp2].each do |micropost|
        expect do
          Micropost.find(micropost)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
