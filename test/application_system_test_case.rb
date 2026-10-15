require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["SELENIUM_HOST"]
    # In docker compose: the browser runs in the chrome service and reaches the app at the web service.
    served_by host: "web", port: 3001
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
    }
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  end
end
