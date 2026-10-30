require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "a first visit gets a nonce that the policy allows" do
    get new_session_path

    nonce = css_select("meta[name=csp-nonce]").first["content"]
    assert_predicate nonce, :present?
    assert_includes response.headers["Content-Security-Policy"], "'nonce-#{nonce}'"
    assert_select "script[type=importmap][nonce=?]", nonce
  end

  test "the nonce stays the same across visits, as Turbo Drive needs" do
    get new_session_path
    nonce = css_select("meta[name=csp-nonce]").first["content"]

    get new_registration_path
    assert_select "meta[name=csp-nonce][content=?]", nonce
  end
end
