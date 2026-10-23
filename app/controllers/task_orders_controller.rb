# A drop of one task onto another, which sends the tasks' new order.
class TaskOrdersController < ApplicationController
  include BoardRendering

  def update
    Current.user.tasks.reposition(params.expect(ids: []))
    render_board
  end
end
