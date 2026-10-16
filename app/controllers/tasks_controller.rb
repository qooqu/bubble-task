class TasksController < ApplicationController
  include BoardRendering

  def create
    task = Current.user.tasks.new(params.expect(task: [ :name ]))

    if task.save
      render_board
    else
      head :unprocessable_content
    end
  end
end
