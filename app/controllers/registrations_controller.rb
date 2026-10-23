class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_registered_users
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  # A guest who signs up keeps their account and its board, with the placeholder
  # email and password replaced by the ones entered.
  def create
    @user = Current.user || User.new
    @user.assign_attributes(registration_params.merge(guest: false))

    if @user.save
      start_new_session_for @user unless Current.session
      redirect_to after_authentication_url, notice: "Welcome to Bubble Task."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def redirect_registered_users
      redirect_to root_path if authenticated? && !Current.user.guest?
    end

    def registration_params
      params.expect(user: [ :email_address, :password, :password_confirmation ])
    end
end
