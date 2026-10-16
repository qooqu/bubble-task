# Board actions answer with the re-rendered board, which Turbo swaps into the page.
module BoardRendering
  private
    # Reloads, so a record that failed to save (e.g. a blank name) isn't left in the association and rendered.
    def render_board
      render turbo_stream: turbo_stream.replace("board", partial: "boards/board",
        locals: { workers: Current.user.workers.reload, tasks: Current.user.tasks.reload })
    end
end
