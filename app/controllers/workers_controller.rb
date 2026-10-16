class WorkersController < ApplicationController
  include BoardRendering

  def create
    Current.user.workers.create(params.expect(worker: [ :name ]))
    render_board
  end
end
