# A drop of one worker onto another, which sends the workers' new order.
class WorkerOrdersController < ApplicationController
  include BoardRendering

  def update
    Current.user.workers.reposition(params.expect(ids: []))
    render_board
  end
end
