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

    %w[ bubble-00 bubble-25 bubble-50 bubble-75 bubble-100 bubble-na ].each do |expected|
      bubble.call.click
      assert_selector "button.#{expected}[aria-label='Paint, Ann']"
    end
  end

  test "clicking a bubble several times quickly" do
    bubble = find_button("Ship, Bob")
    assert_includes bubble[:class], "bubble-50"

    3.times { bubble.click }
    assert_selector "button.bubble-na[aria-label='Ship, Bob']"
    assert_no_selector "[aria-busy]"

    visit root_path
    assert_selector "button.bubble-na[aria-label='Ship, Bob']"
  end

  test "dragging a task onto another to reorder, and onto the trash to delete it" do
    fill_in "New task name", with: "Paint"
    send_keys :enter
    assert_selector "#board tbody th", text: "Paint"

    find("#board tbody th", text: "Paint").drag_to find("#board tbody th", text: "Ship")
    assert_selector "#board tbody tr:first-child th", text: "Paint"

    find("#board tbody th", text: "Ship").drag_to find("#board [aria-label=Trash]")
    assert_no_selector "#board tbody th", text: "Ship"
    assert_selector "#board tbody th", text: "Paint"
  end
end
