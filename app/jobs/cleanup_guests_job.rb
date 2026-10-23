# Deletes stale guest accounts and their boards. Scheduled in config/recurring.yml.
class CleanupGuestsJob < ApplicationJob
  def perform
    User.guests.where(created_at: ...User::GUEST_LIFETIME.ago).find_each(&:destroy)
  end
end
