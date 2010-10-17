class User < ActiveRecord::Base
  attr_accessor :password

  # these are the only attributes that can be updated using #update_attributes
  attr_accessible :name, :email, :password, :password_confirmation

  validates :name, :presence => true, 
                   :length => { :maximum => 50 }
  validates :email, :presence => true, 
                    :format => { :with => /\A[\w.\-]+@[\w.\-]+\.\w+\z/ },
                    :uniqueness => { :case_sensitive => false }
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }
end
