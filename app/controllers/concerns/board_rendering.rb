# Board actions answer with the re-rendered board, which Turbo swaps into the page.
module BoardRendering
  private
    def render_board
      render turbo_stream: turbo_stream.replace("board", partial: "boards/board",
        locals: { workers: Current.user.workers, tasks: Current.user.tasks })
    end
end
