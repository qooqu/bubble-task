require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "create signs up and logs in" do
    assert_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "New@Example.com", password: "secret", password_confirmation: "secret" } }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert_equal "new@example.com", User.last.email_address
  end

  test "create with an email address already taken, regardless of case" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: users(:one).email_address.upcase, password: "secret", password_confirmation: "secret" } }
    end

    assert_response :unprocessable_entity
    assert_select "li", "Email address has already been taken"
    assert_nil cookies[:session_id]
  end

  test "create with an invalid email address" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "not-an-email", password: "secret", password_confirmation: "secret" } }
    end

    assert_response :unprocessable_entity
    assert_select "li", "Email address is invalid"
  end

  test "create with a password confirmation that doesn't match" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "new@example.com", password: "secret", password_confirmation: "other" } }
    end

    assert_response :unprocessable_entity
  end

  test "create as a guest converts the guest, keeping their board" do
    post guest_path
    guest = User.last

    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "new@example.com", password: "secret", password_confirmation: "secret" } }
    end

    assert_redirected_to root_path
    guest.reload
    assert_not guest.guest?
    assert_equal "new@example.com", guest.email_address
    assert_equal %w[ Jack Jill ], guest.workers.map(&:name)

    delete session_path
    post session_path, params: { email_address: "new@example.com", password: "secret" }
    follow_redirect!
    assert_select "nav", /new@example\.com/
    assert_select "#board tbody th", 2
  end

  test "create as a guest with an email address already taken leaves the guest as is" do
    post guest_path
    guest = User.last

    post registration_path, params: { user: { email_address: users(:one).email_address, password: "secret", password_confirmation: "secret" } }

    assert_response :unprocessable_entity
    assert_select "nav", /Guest/
    assert_select "nav button", { text: "Log out", count: 0 }
    assert guest.reload.guest?
    assert_match(/guest\.invalid\z/, guest.email_address)
  end

  test "new and create send a registered user back to the board" do
    sign_in_as users(:one)

    get new_registration_path
    assert_redirected_to root_path

    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "new@example.com", password: "secret", password_confirmation: "secret" } }
    end
    assert_redirected_to root_path
  end
end
