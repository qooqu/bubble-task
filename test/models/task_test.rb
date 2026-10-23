require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "advance! assigns an unassigned task at 0%" do
    task = tasks(:plan)

    task.advance!(workers(:jack))

    assert_equal workers(:jack), task.reload.worker
    assert_equal 0, task.percent_complete
  end

  test "advance! steps progress by 25% for the assigned worker" do
    task = tasks(:build)

    task.advance!(workers(:jack))

    assert_equal 50, task.reload.percent_complete
    assert_equal workers(:jack), task.worker
  end

  test "advance! reaches 100%" do
    task = tasks(:build)
    task.update!(percent_complete: 75)

    task.advance!(workers(:jack))

    assert_equal 100, task.reload.percent_complete
  end

  test "advance! unassigns a finished task" do
    task = tasks(:build)
    task.update!(percent_complete: 100)

    task.advance!(workers(:jack))

    assert_nil task.reload.worker
    assert_equal 0, task.percent_complete
  end

  test "advance! ignores another worker while the task is assigned" do
    task = tasks(:build)

    assert_no_changes -> { task.reload.attributes.values_at("worker_id", "percent_complete") } do
      task.advance!(workers(:jill))
    end
  end

  test "percent_complete must be a 25% step" do
    task = tasks(:build)
    task.percent_complete = 30

    assert_not task.valid?
  end

  test "can't be assigned to another user's worker" do
    assert_raises(ActiveRecord::RecordInvalid) { tasks(:plan).advance!(workers(:bob)) }
  end

  test "requires a name" do
    assert_not Task.new(user: users(:one)).valid?
  end

  test "strips surrounding whitespace from the name" do
    assert_equal "Celebrate", Task.new(name: "  Celebrate  ").name
  end

  test "name can be at most 50 characters" do
    assert Task.new(user: users(:one), name: "a" * 50).valid?
    assert_not Task.new(user: users(:one), name: "a" * 51).valid?
  end

  test "new tasks go to the end of their user's list" do
    task = users(:one).tasks.create!(name: "Celebrate")

    assert_equal 3, task.position
    assert_equal 1, users(:two).tasks.create!(name: "Rest").position
  end

  test "reposition sets positions in the given order" do
    users(:one).tasks.reposition([ tasks(:plan).id, tasks(:build).id, tasks(:sell).id ])

    assert_equal [ tasks(:plan), tasks(:build), tasks(:sell) ], users(:one).tasks.to_a
  end

  test "reposition updates updated_at" do
    travel 1.minute do
      users(:one).tasks.reposition([ tasks(:sell).id, tasks(:build).id ])

      assert_equal Time.current, tasks(:sell).reload.updated_at
    end
  end

  test "reposition through an association ignores other users' tasks" do
    assert_no_changes -> { tasks(:ship).reload.position } do
      users(:one).tasks.reposition([ tasks(:sell).id, tasks(:ship).id ])
    end
  end
end
