class User < ApplicationRecord
  GUEST_LIFETIME = 24.hours

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tasks, -> { order(:position) }, dependent: :delete_all
  has_many :workers, -> { order(:position) }, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  # A guest never sees their random password, so signing up has to replace it.
  validates :password, presence: true, if: -> { guest_changed?(from: true, to: false) }

  scope :guests, -> { where(guest: true) }

  # A sandbox account for "Try it out", seeded with the old app's demo board. The
  # .invalid address can never receive mail, and the password is never shown.
  def self.create_guest!
    transaction do
      create!(guest: true, email_address: "guest-#{SecureRandom.hex(8)}@guest.invalid", password: SecureRandom.base58(24)).tap do |user|
        jack, jill = user.workers.create!([ { name: "Jack" }, { name: "Jill" } ])
        user.tasks.create!(name: "Build", worker: jack, percent_complete: 25)
        user.tasks.create!(name: "Sell", worker: jill)
      end
    end
  end

  # When CleanupGuestsJob may delete this guest and their board.
  def expires_at
    created_at + GUEST_LIFETIME
  end
end
