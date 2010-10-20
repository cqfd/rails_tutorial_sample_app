require 'spec_helper'

describe "FriendlyForwardings" do
  it "should forward to the previously requested page after signin" do
    user = Factory(:user)
    visit edit_user_path(user) # redirect will be automatically followed

    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button # again, redirect will be automatically followed

    response.should render_template('users/edit')
  end

  it "should not friendly forward after a user signs out and then back in" do
    user = Factory(:user)

    visit edit_user_path(user) # redirect will be automatically followed

    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button # again, redirect will be automatically followed

    visit signout_path

    visit signin_path
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button # again, redirect will be automatically followed

    response.should render_template('users/show')
  end
end
