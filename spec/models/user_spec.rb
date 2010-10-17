require 'spec_helper'

describe User do
  let(:attr) { 
    {:name => "Example User", :email => "user@example.com",
     :password => "password", :password_confirmation => "password"}
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
    let(:user) { User.create! attr }
    it "should have an encrypted password attribute" do
      user.should respond_to(:encrypted_password)
    end
  end
end
