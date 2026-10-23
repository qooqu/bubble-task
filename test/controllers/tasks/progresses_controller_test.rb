require "test_helper"

class Tasks::ProgressesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "update advances the task for the clicked worker and re-renders the board" do
    patch task_progress_path(tasks(:build), worker_id: workers(:jack).id), as: :turbo_stream

    assert_equal 50, tasks(:build).reload.percent_complete
    assert_turbo_stream action: :replace, target: "board" do
      assert_select "button.bubble-50", 1
    end
  end

  test "update can't touch another user's task" do
    patch task_progress_path(tasks(:ship), worker_id: workers(:jack).id), as: :turbo_stream

    assert_response :not_found
    assert_equal 50, tasks(:ship).reload.percent_complete
  end

  test "update can't assign another user's worker" do
    patch task_progress_path(tasks(:plan), worker_id: workers(:bob).id), as: :turbo_stream

    assert_response :not_found
    assert_nil tasks(:plan).reload.worker
  end
end
