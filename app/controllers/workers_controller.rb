class WorkersController < ApplicationController
  include BoardRendering

  def create
    worker = Current.user.workers.new(params.expect(worker: [ :name ]))

    if worker.save
      render_board
    else
      head :unprocessable_content
    end
  end

  def destroy
    Current.user.workers.find(params[:id]).destroy!
    render_board
  end
end
