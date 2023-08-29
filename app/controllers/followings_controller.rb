class FollowingsController < ApplicationController
  before_action :logged_in_user, :load_user, only: :index

  def index
    @title = t "relations.title.following"
    @users = @user.following.paginate(page: params[:page])
    render "show_follow", status: :unprocessable_entity
  end

  private

  def load_user
    @user = User.find_by id: params[:id]
    return unless @user.nil?
    redirect_to :root,
                flash: {warning: t("flash.users.not_found")}
  end
end
