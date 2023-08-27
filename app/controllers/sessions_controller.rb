class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      if user.activated?
        handle_if_authenticated_and_inactive user
      else
        flash[:warning] = t "account.activate.message"
        redirect_to root_url
      end
    else
      error_handle
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end

  private

  def handle_if_authenticated_and_inactive user
    forwarding_url = session[:forwarding_url]
    reset_session
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
    log_in user
    redirect_to forwarding_url || user
  end

  def error_handle
    flash.now[:danger] = t("flash.users.danger")
    render :new, status: :unprocessable_entity
  end
end
