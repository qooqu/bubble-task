require "test_helper"

class WorkerOrdersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "update puts the current user's workers in the given order and re-renders the board" do
    patch worker_order_path, params: { ids: [ workers(:jill).id, workers(:jack).id ] }, as: :turbo_stream

    assert_equal %w[ Jill Jack ], users(:one).workers.map(&:name)
    assert_turbo_stream action: :replace, target: "board" do
      assert_select "thead th[scope=col]" do |headers|
        assert_equal %w[ Jill Jack ], headers.map(&:text)
      end
    end
  end

  test "update ignores another user's workers" do
    assert_no_changes -> { workers(:bob).reload.position } do
      patch worker_order_path, params: { ids: [ workers(:jill).id, workers(:bob).id, workers(:jack).id ] }, as: :turbo_stream
    end

    assert_response :success
  end
end
