class UsersController < ApplicationController
  def show
    @user = User.find_by id: params[:id]
    redirect_to :root, flash: { warning: t("flash.users.not_found") } if @user.nil?
    # debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
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
