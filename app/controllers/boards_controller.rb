class BoardsController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    return render :landing unless authenticated?

    @workers = Current.user.workers
    @tasks = Current.user.tasks
  end
end
