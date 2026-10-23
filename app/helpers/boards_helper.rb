module BoardsHelper
  # The bubble's fill: empty-grey when the task isn't assigned to this worker,
  # otherwise filled to the task's progress (bubble-00 … bubble-100).
  def bubble_class(task, worker)
    return "bubble bubble-na" unless task.worker_id == worker.id

    "bubble bubble-#{task.percent_complete.to_s.rjust(2, "0")}"
  end

  # Whole hours left until time, rounded up: "24 hours", "1 hour".
  def hours_until(time)
    pluralize(((time - Time.current) / 1.hour).ceil.clamp(0..), "hour")
  end
end
