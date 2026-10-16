require "test_helper"

class BoardsControllerTest < ActionDispatch::IntegrationTest
  test "show requires logging in" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "show greets a logged-in user in the nav" do
    sign_in_as users(:one)

    get root_path

    assert_response :success
    assert_select "nav", /#{users(:one).email_address}/
    assert_select "nav button", "Log out"
  end
end
