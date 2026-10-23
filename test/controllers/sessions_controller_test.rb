require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "create returns to the page that asked for a login" do
    get root_path(page: 2)
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_url(page: 2)
  end

  test "create doesn't return to a non-GET request that asked for a login" do
    delete session_path
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
  end

  test "create without an email address" do
    post session_path, params: { password: "password" }

    assert_response :bad_request
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "create as a guest logs in to the registered account instead" do
    post guest_path
    post session_path, params: { email_address: @user.email_address, password: "password" }
    follow_redirect!

    assert_select "nav", /#{@user.email_address}/
  end
end
