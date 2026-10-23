require "test_helper"

class TaskOrdersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "update puts the current user's tasks in the given order and re-renders the board" do
    patch task_order_path, params: { ids: [ tasks(:plan), tasks(:build), tasks(:sell) ].map(&:id) }, as: :turbo_stream

    assert_equal %w[ Plan Build Sell ], users(:one).tasks.map(&:name)
    assert_turbo_stream action: :replace, target: "board" do
      assert_select "tbody th" do |rows|
        assert_equal %w[ Plan Build Sell ], rows.map(&:text)
      end
    end
  end

  test "update ignores another user's tasks" do
    assert_no_changes -> { tasks(:ship).reload.position } do
      patch task_order_path, params: { ids: [ tasks(:sell), tasks(:build), tasks(:ship) ].map(&:id) }, as: :turbo_stream
    end

    assert_response :success
  end
end
