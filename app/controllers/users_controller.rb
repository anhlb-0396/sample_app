class UsersController < ApplicationController
  def show
    @user = User.find_by id: params[:id]
    return unless @user.nil?

    redirect_to :root,
                flash: {warning: t("flash.users.not_found")}

    # debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      reset_session
      log_in @user
      flash[:success] = t("flash.users.success")
      redirect_to @user
    else
      render "new", status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
