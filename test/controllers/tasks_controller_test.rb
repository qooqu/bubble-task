require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "create adds an unassigned task to the end of the current user's board" do
    assert_difference -> { users(:one).tasks.count } do
      post tasks_path, params: { task: { name: "Celebrate" } }, as: :turbo_stream
    end

    task = users(:one).tasks.last
    assert_equal "Celebrate", task.name
    assert_nil task.worker
    assert_turbo_stream action: :replace, target: "board" do
      assert_select "tbody th", "Celebrate"
    end
  end

  test "create with a blank name adds nothing" do
    assert_no_difference -> { Task.count } do
      post tasks_path, params: { task: { name: "" } }, as: :turbo_stream
    end
  end
end
