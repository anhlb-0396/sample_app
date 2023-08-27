class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(show new create)
  before_action :load_all_users, only: :index
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index; end

  def show
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
      @user.send_activation_email
      flash[:info] = t "account.activate.check_email"
      redirect_to root_url
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      flash[:success] = t "flash.users.profile_updated"
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit; end

  def destroy
    @user.destroy
    flash[:success] = t "flash.users.delete"
    redirect_to users_url, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "flash.users.login"
    redirect_to login_url, status: :see_other
  end

  # Confirms the correct user.
  def correct_user
    return if current_user? @user

    redirect_to(root_url, status: :see_other,
flash: {danger: t("flash.users.incorrect_user")})
  end

  # Confirms an admin user.
  def admin_user
    return if current_user.admin?

    redirect_to(root_url, status: :see_other,
flash: {danger: t("flash.users.not_admin")})
  end

  def load_all_users
    @users = User.paginate(page: params[:page])
  end

  def load_user
    @user = User.find_by id: params[:id]
    return unless @user.nil?

    redirect_to :root,
                flash: {warning: t("flash.users.not_found")}
  end
end
