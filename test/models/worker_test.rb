require "test_helper"

class WorkerTest < ActiveSupport::TestCase
  test "requires a name" do
    assert_not Worker.new(user: users(:one)).valid?
  end

  test "strips surrounding whitespace from the name" do
    assert_equal "Celebrate", Worker.new(name: "  Celebrate  ").name
  end

  test "name can be at most 50 characters" do
    assert Worker.new(user: users(:one), name: "a" * 50).valid?
    assert_not Worker.new(user: users(:one), name: "a" * 51).valid?
  end

  test "new workers go to the end of their user's list" do
    assert_equal 2, users(:one).workers.create!(name: "Pat").position
  end

  test "deleting a worker unassigns its tasks and resets their progress" do
    workers(:jack).destroy

    assert_nil tasks(:build).reload.worker
    assert_equal 0, tasks(:build).percent_complete
  end

  test "deleting a worker updates its tasks' updated_at" do
    travel 1.minute do
      workers(:jack).destroy

      assert_equal Time.current, tasks(:build).reload.updated_at
    end
  end

  test "deleting a worker leaves other workers' tasks alone" do
    workers(:jack).destroy

    assert_equal workers(:jill), tasks(:sell).reload.worker
    assert_equal workers(:bob), tasks(:ship).reload.worker
    assert_equal 50, tasks(:ship).percent_complete
  end

  test "reposition sets positions in the given order" do
    users(:one).workers.reposition([ workers(:jill).id, workers(:jack).id ])

    assert_equal [ workers(:jill), workers(:jack) ], users(:one).workers.to_a
  end
end
