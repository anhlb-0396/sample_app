class User < ApplicationRecord
  attr_accessor :remember_token

  before_save :downcase_email

  validates :name, presence: true,
            length: {maximum: Settings.validate.name.length.max}

  validates :email, presence: true,
            length: {maximum: Settings.validate.email.length.max},
            format: {with: Regexp.new(Settings.validate.email.regex,
                                      Regexp::IGNORECASE)}, uniqueness: true

  has_secure_password
  validates :password, presence: true,
            length: {minimum: Settings.validate.password.length.min}

  # Returns the hash digest of the given string.

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost:)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  # Returns true if the given token matches the digest.
  def authenticated? remember_token
    return false if remember_digest.nil?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  private

  def downcase_email
    email.downcase!
  end
end
