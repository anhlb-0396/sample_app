class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by id: params[:followed_id]
    if @user.nil?
      redirect_to root_path,
                  flash: {warning: t("flash.users.not_found")}
    end
    current_user.follow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find_by(id: params[:id])&.followed
    if @user.nil?
      redirect_to root_path,
                  flash: {warning: t("flash.users.not_found")}
    end
    current_user.unfollow(@user)
    respond_to do |format|
      format.html{redirect_to @user, status: :see_other}
      format.turbo_stream
    end
  end
end
