# Deletes stale guest accounts and their boards. Scheduled in config/recurring.yml.
class CleanupGuestsJob < ApplicationJob
  def perform
    User.guests.where(created_at: ...7.days.ago).destroy_all
  end
end
