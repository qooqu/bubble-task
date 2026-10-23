require "test_helper"

class GuestsControllerTest < ActionDispatch::IntegrationTest
  test "create logs in a new guest with the demo board" do
    assert_difference -> { User.guests.count } do
      post guest_path
    end

    assert_redirected_to root_path
    follow_redirect!

    assert_select "nav", /Guest/
    assert_select "nav", { text: /guest\.invalid/, count: 0 }
    assert_select "p", /Welcome to Bubble Task!/
    assert_select "p", /This sandbox is deleted in/
    assert_select "p time[datetime=?]", User.last.expires_at.iso8601
    assert_select "#board thead th[scope=col]" do |headers|
      assert_equal %w[ Jack Jill ], headers.map(&:text)
    end
    assert_select "#board tbody th" do |rows|
      assert_equal %w[ Build Sell ], rows.map(&:text)
    end
  end
end
