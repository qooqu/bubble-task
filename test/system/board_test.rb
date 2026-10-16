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
    fill_in "New worker name", with: "Ann"
    send_keys :enter
    assert_selector "#board thead th", text: "Ann"
    assert_field "New worker name", with: ""

    fill_in "New task name", with: "Paint"
    send_keys :enter
    assert_selector "#board tbody th", text: "Paint"

    bubble = -> { find_button("Paint, Ann") }
    assert_includes bubble.call[:class], "bubble-na"

    begin
      %w[ bubble-00 bubble-25 bubble-50 bubble-75 bubble-100 bubble-na ].each do |expected|
        bubble.call.click
        assert_selector "button.#{expected}[aria-label='Paint, Ann']"
      end
    rescue Minitest::Assertion
      puts "=== DEBUG test.log tail"
      puts File.readlines("log/test.log").last(60).grep_v(/^\s*$/).join
      puts "=== DEBUG board html"
      puts find("#board")["outerHTML"][0, 3000]
      raise
    end
  end
end
