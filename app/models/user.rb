class User < ActiveRecord::Base
  # these are the only attributes that can be updated using #update_attributes
  attr_accessible :name, :email

  validates :name, :presence => true, 
                   :length => { :maximum => 50 }
  validates :email, :presence => true, 
                    :format => { :with => /\A[\w.\-]+@[\w.\-]+\.\w+\z/ },
                    :uniqueness => { :case_sensitive => false }
end
