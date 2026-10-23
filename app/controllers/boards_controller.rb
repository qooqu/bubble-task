class BoardsController < ApplicationController
  def show
    @workers = Current.user.workers
    @tasks = Current.user.tasks
  end
end
