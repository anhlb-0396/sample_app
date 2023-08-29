class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      handle_if_success
    else
      handle_if_fail
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t "microposts.deleted"
    if request.referer.nil?
      redirect_to root_url, status: :see_other
    else
      redirect_to request.referer, status: :see_other
    end
  end

  private

  def handle_if_success
    flash[:success] = t "microposts.created"
    redirect_to root_url
  end

  def handle_if_fail
    @feed_items = current_user.feed.paginate(page: params[:page])
    render "static_pages/home", status: :unprocessable_entity
  end

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url, status: :see_other if @micropost.nil?
  end
end
