require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires an email address and a password" do
    user = User.new

    assert_not user.valid?
    assert_includes user.errors[:email_address], "can't be blank"
    assert_includes user.errors[:password], "can't be blank"
  end

  test "rejects an invalid email address" do
    user = User.new(email_address: "not-an-email", password: "secret")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "is invalid"
  end

  test "rejects an email address already taken, regardless of case" do
    user = User.new(email_address: users(:one).email_address.upcase, password: "secret")

    assert_not user.valid?
    assert_includes user.errors[:email_address], "has already been taken"
  end

  test "rejects a password confirmation that doesn't match" do
    user = User.new(email_address: "new@example.com", password: "secret", password_confirmation: "other")

    assert_not user.valid?
    assert_includes user.errors[:password_confirmation], "doesn't match Password"
  end

  test "rejects a password longer than bcrypt allows" do
    user = User.new(email_address: "new@example.com", password: "a" * 73)

    assert_not user.valid?
    assert_not_empty user.errors[:password]
  end

  test "keeps its password when updated without one" do
    user = users(:one)

    assert user.update(email_address: "changed@example.com")
  end

  test "deleting a user deletes their workers and tasks" do
    user = users(:one)

    assert_difference -> { Worker.count } => -2, -> { Task.count } => -3 do
      user.destroy
    end
  end

  test "create_guest! creates a guest with a placeholder email and the demo board" do
    guest = User.create_guest!

    assert guest.guest?
    assert_match(/\Aguest-\h{16}@guest\.invalid\z/, guest.email_address)
    assert_equal %w[ Jack Jill ], guest.workers.map(&:name)
    assert_equal [ [ "Build", "Jack", 25 ], [ "Sell", "Jill", 0 ] ],
      guest.tasks.map { |task| [ task.name, task.worker.name, task.percent_complete ] }
  end

  test "a guest signing up must choose a new password" do
    guest = User.find(User.create_guest!.id)

    assert_not guest.update(email_address: "new@example.com", guest: false)
    assert_includes guest.errors[:password], "can't be blank"
  end

  test "a guest is deleted on CleanupGuestsJob's first run after 24 hours" do
    guest = User.new(created_at: Time.zone.local(2026, 10, 23, 9, 15))
    assert_equal Time.zone.local(2026, 10, 24, 9, 42), guest.deletion_time

    guest.created_at = Time.zone.local(2026, 10, 23, 9, 50)
    assert_equal Time.zone.local(2026, 10, 24, 10, 42), guest.deletion_time

    guest.created_at = Time.zone.local(2026, 10, 23, 9, 42)
    assert_equal Time.zone.local(2026, 10, 24, 10, 42), guest.deletion_time
  end
end
