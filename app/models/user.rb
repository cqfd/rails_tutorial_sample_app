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

  before_save :encrypt_password

  def self.authenticate email, password
    user = self.find_by_email email
    user && user.has_password?(password) ? user : nil
  end

  def has_password? guess
    encrypted_password == encrypt(guess)
  end

  private
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt password
    end

    def encrypt string
      secure_hash "#{salt}--#{string}"
    end

    def secure_hash string
      Digest::SHA2.hexdigest string
    end

    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
end
