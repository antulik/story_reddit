class HomeController < ApplicationController

  def index
  end

  def direct_login
    if logged_in? && current_user.story_user_id != params[:user_id].to_i
      logout
    end

    if logged_in?
      redirect_to :root
    else
      redirect_to '/auth/story'
    end
  end

  def fetch_reddit
    sync = RedditSynchronizer.new(current_user)

    sync.sync_popular_subreddits
    head :ok
  end
end
