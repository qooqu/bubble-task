require "test_helper"

class BoardsHelperTest < ActionView::TestCase
  test "hours_until rounds to the nearest hour, at most 24" do
    assert_equal "about 24 hours", hours_until(24.hours.from_now + 50.minutes)
    assert_equal "about 6 hours", hours_until(5.hours.from_now + 40.minutes)
    assert_equal "about 1 hour", hours_until(1.hour.from_now + 10.minutes)
  end

  test "hours_until says less than 1 hour at the end" do
    assert_equal "less than 1 hour", hours_until(59.minutes.from_now)
    assert_equal "less than 1 hour", hours_until(5.minutes.ago)
  end
end
