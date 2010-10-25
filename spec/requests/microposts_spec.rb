require 'spec_helper'

describe "Microposts" do
  before(:each) do
    user = Factory(:user)
    visit signin_path
    fill_in :email, :with => user.email
    fill_in :password, :with => user.password
    click_button
  end

  describe "creation" do
    context "failure" do
      it "does not make a new micropost" do
        expect do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button

          response.should render_template('pages/home')
          response.should have_selector('div#error_explanation')
        end.to_not change(Micropost, :count)
      end
    end

    context "success" do
      it "does make a new micropost" do
        expect do
          content = "lorem ipsum dolor sit amet"
          visit root_path
          fill_in :micropost_content, :with => content
          click_button

          response.should have_selector('span.content', :content => content)
        end.to change(Micropost, :count).by(1)
      end
    end
  end
end
