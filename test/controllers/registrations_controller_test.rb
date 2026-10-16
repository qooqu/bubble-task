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
    assert_select "li", "email address has already been taken"
    assert_nil cookies[:session_id]
  end

  test "create with an invalid email address" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "not-an-email", password: "secret", password_confirmation: "secret" } }
    end

    assert_response :unprocessable_entity
    assert_select "li", "email address is invalid"
  end

  test "create with a password confirmation that doesn't match" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "new@example.com", password: "secret", password_confirmation: "other" } }
    end

    assert_response :unprocessable_entity
  end
end
