module BoardsHelper
  # The bubble's fill: empty-grey when the task isn't assigned to this worker,
  # otherwise filled to the task's progress (bubble-00 … bubble-100).
  def bubble_class(task, worker)
    return "bubble bubble-na" unless task.worker_id == worker.id

    "bubble bubble-#{task.percent_complete.to_s.rjust(2, "0")}"
  end

  # Hours left until time, to the nearest hour and at most 24: "about 24 hours",
  # "about 1 hour", or "less than 1 hour".
  def hours_until(time)
    hours_left = (time - Time.current) / 1.hour
    return "less than 1 hour" if hours_left < 1

    "about #{pluralize(hours_left.round.clamp(..24), "hour")}"
  end
end
