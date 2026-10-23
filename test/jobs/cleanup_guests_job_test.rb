require "test_helper"

class CleanupGuestsJobTest < ActiveJob::TestCase
  test "deletes guests older than a day, along with their boards" do
    stale = travel_to(25.hours.ago) { User.create_guest! }
    fresh = travel_to(23.hours.ago) { User.create_guest! }

    assert_difference -> { Worker.count } => -2, -> { Task.count } => -2 do
      CleanupGuestsJob.perform_now
    end

    assert_not User.exists?(stale.id)
    assert User.exists?(fresh.id)
    assert User.exists?(users(:one).id)
  end

  test "is scheduled at its MINUTE past each hour" do
    schedule = YAML.load_file(Rails.root.join("config/recurring.yml")).dig("production", "cleanup_guests", "schedule")
    assert_equal "every hour at minute #{CleanupGuestsJob::MINUTE}", schedule
  end

  test "keeps registered users however old they are" do
    users(:one).update_columns(created_at: 1.year.ago)

    assert_no_difference -> { User.count } do
      CleanupGuestsJob.perform_now
    end
  end
end
