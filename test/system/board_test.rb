require "application_system_test_case"

class BoardTest < ApplicationSystemTestCase
  setup do
    visit new_session_path
    fill_in placeholder: "Email", with: users(:two).email_address
    fill_in placeholder: "Password", with: "password"
    click_button "Log in"
    assert_text users(:two).email_address
  end

  test "adding a worker and a task, then clicking a bubble through its whole cycle" do
    Capybara.default_max_wait_time = 10
    started = Time.now
    run_steps
    puts "=== DEBUG passed in #{(Time.now - started).round(2)}s"
    puts File.readlines("log/test.log").grep(/Started|Completed/).last(40).join
  rescue Minitest::Assertion
    puts "=== DEBUG failed after #{(Time.now - started).round(2)}s"
    puts File.readlines("log/test.log").grep(/Started|Completed|Error|error/).last(40).join
    raise
  end

  def run_steps
    fill_in "New worker name", with: "Ann"
    send_keys :enter
    assert_selector "#board thead th", text: "Ann"
    assert_field "New worker name", with: ""

    fill_in "New task name", with: "Paint"
    send_keys :enter
    assert_selector "#board tbody th", text: "Paint"

    bubble = -> { find_button("Paint, Ann") }
    assert_includes bubble.call[:class], "bubble-na"

    %w[ bubble-00 bubble-25 bubble-50 bubble-75 bubble-100 bubble-na ].each do |expected|
      bubble.call.click
      assert_selector "button.#{expected}[aria-label='Paint, Ann']"
    end
  end
end
