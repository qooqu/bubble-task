class TasksController < ApplicationController
  include BoardRendering

  def create
    Current.user.tasks.create(params.expect(task: [ :name ]))
    render_board
  end
end
