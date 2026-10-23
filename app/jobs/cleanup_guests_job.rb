# Deletes stale guest accounts and their boards. Scheduled in config/recurring.yml.
class CleanupGuestsJob < ApplicationJob
  # The minute past each hour it runs at. Must match config/recurring.yml.
  MINUTE = 42

  def perform
    User.guests.where(created_at: ...User::GUEST_LIFETIME.ago).find_each(&:destroy)
  end
end
