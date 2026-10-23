# Deletes stale guest accounts and their boards. Runs every hour, on the hour
# (config/recurring.yml), which User#deletion_time relies on.
class CleanupGuestsJob < ApplicationJob
  def perform
    User.guests.where(created_at: ...User::GUEST_LIFETIME.ago).find_each(&:destroy)
  end
end
