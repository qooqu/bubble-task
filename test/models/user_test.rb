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
end
