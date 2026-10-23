# A click on a task's bubble in a worker's column.
class Tasks::ProgressesController < ApplicationController
  include BoardRendering

  def update
    task = Current.user.tasks.find(params[:task_id])
    task.advance!(Current.user.workers.find(params.expect(:worker_id)))
    render_board
  end
end
