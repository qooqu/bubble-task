# "Try it out": logs the visitor in as a new guest with a seeded sandbox board.
class GuestsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def create
    start_new_session_for User.create_guest!
    redirect_to root_path
  end
end
