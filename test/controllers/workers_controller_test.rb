require "test_helper"

class WorkersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "create adds a worker to the end of the current user's board" do
    assert_difference -> { users(:one).workers.count } do
      post workers_path, params: { worker: { name: "Pat" } }, as: :turbo_stream
    end

    assert_equal "Pat", users(:one).workers.last.name
    assert_turbo_stream action: :replace, target: "board" do
      assert_select "thead th", "Pat"
    end
  end

  test "create with a blank name adds nothing and fails, so the form keeps its text" do
    assert_no_difference -> { Worker.count } do
      post workers_path, params: { worker: { name: "  " } }, as: :turbo_stream
    end

    assert_response :unprocessable_content
  end

  test "destroy deletes the worker, unassigns its tasks and re-renders the board" do
    assert_difference -> { users(:one).workers.count }, -1 do
      delete worker_path(workers(:jack)), as: :turbo_stream
    end

    assert_nil tasks(:build).reload.worker
    assert_turbo_stream action: :replace, target: "board" do
      assert_select "thead th[scope=col]" do |headers|
        assert_equal %w[ Jill ], headers.map(&:text)
      end
    end
  end

  test "destroy can't touch another user's worker" do
    assert_no_difference -> { Worker.count } do
      delete worker_path(workers(:bob)), as: :turbo_stream
    end

    assert_response :not_found
  end

  test "create requires logging in" do
    sign_out

    assert_no_difference -> { Worker.count } do
      post workers_path, params: { worker: { name: "Pat" } }, as: :turbo_stream
    end
    assert_redirected_to new_session_path
  end
end
