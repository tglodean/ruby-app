class User < ActiveRecord::Base

  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
  class_name:  "Relationship",
  dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  before_save { self.email = email.downcase }
  # before_save { email.downcase! }
  before_create { create_token(:remember_token) }
  after_create { set_user_state_false }

  validates :name, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }

  has_secure_password
  def feed
    Micropost.from_users_followed_by(self)
    Micropost.from_users_followed_by_including_replies(self)
  end

  def self.search(query)
    where("email like ?", "%#{query}%")
  end
  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end
  def send_password_reset
   create_token(:password_reset_token)
   self.password_reset_sent_at = Time.zone.now
   save! validate: false
   UserMailer.password_reset(self).deliver
  end
  def send_email_confirm
    create_token(:email_confirm_token)
    save! validate: false
    UserMailer.email_confirm(self).deliver
  end
  def set_user_state_false
    self.toggle!(:user_state)
  end
  private

  def create_token(param)
    self[param] = User.digest(User.new_remember_token)
  end

end
