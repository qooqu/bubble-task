require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  test "show requires logging in, and creates no guest" do
    assert_no_difference -> { User.count } do
      get root_path
    end
    assert_redirected_to new_session_path
  end

  test "show greets a logged-in user in the nav" do
    sign_in_as users(:one)

    get root_path

    assert_response :success
    assert_select "nav", /#{users(:one).email_address}/
    assert_select "nav button", "Log out"
    assert_select "p", { text: /Welcome/, count: 0 }
  end

  test "show lays out the current user's workers and tasks in order" do
    sign_in_as users(:one)

    get root_path

    assert_select "#board thead th[scope=col]" do |headers|
      assert_equal %w[ Jack Jill ], headers.map(&:text)
    end
    assert_select "#board tbody th" do |rows|
      assert_equal %w[ Build Sell Plan ], rows.map(&:text)
    end
    assert_select "#board button.bubble", 6
    assert_select "#board", { text: /Bob|Ship/, count: 0 }
  end
end
