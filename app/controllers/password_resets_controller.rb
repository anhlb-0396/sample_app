class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "password_reset.send_email"
      redirect_to root_url
    else
      flash.now[:danger] = t "password_reset.email_not_found"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, t("password_reset.password_not_empty"))
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      reset_session
      log_in @user
      flash[:success] = t "password_reset.password_has_reseted"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Before filters

  def get_user
    @user = User.find_by(email: params[:email])
    return unless @user.nil?
    redirect_to :root,
                flash: {warning: t("flash.users.not_found")}
  end

  # Confirms a valid user.
  def valid_user
    unless @user&.activated? &&
           @user&.authenticated?(:reset, params[:id])
      redirect_to root_url
    end
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "password_reset.expire"
    redirect_to new_password_reset_url
  end
end
