require "test_helper"

# Let finders match fields and buttons by their aria-label, as screen readers do.
Capybara.enable_aria_label = true

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Google Chrome (in CI) checks passwords against known breaches after a login and opens a
  # "Change your password" dialog for leaked ones like the fixtures' "password". The dialog
  # swallows the test's later clicks and keystrokes, so turn the password manager off.
  CHROME_OPTIONS = ->(options) do
    options.add_preference("credentials_enable_service", false)
    options.add_preference("profile.password_manager_enabled", false)
    options.add_preference("profile.password_manager_leak_detection", false)
  end

  if ENV["SELENIUM_HOST"]
    # In docker compose: the browser runs in the chrome service and reaches the app at the web service.
    # No fixed port, so parallel test workers each get their own.
    served_by host: "web", port: nil
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
    }, &CHROME_OPTIONS
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], &CHROME_OPTIONS
  end
end
