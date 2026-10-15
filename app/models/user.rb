class User < ApplicationRecord
  # Rails' built-in validations would require a password from guests too, so the equivalents are below.
  has_secure_password validations: false
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: :guest?
  validates :password, presence: true, unless: -> { guest? || password_digest? }
  validates :password, confirmation: true, allow_nil: true
  validate :password_fits_bcrypt

  private
    def password_fits_bcrypt
      errors.add(:password, :password_too_long) if password.to_s.bytesize > ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED
    end
end
