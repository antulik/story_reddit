class SessionsController < ApplicationController
  def create

    if params[:provider] == 'story'
      @user = User.where(:username => auth_hash.uid.to_s).first_or_initialize

      @user.story_token   = auth_hash['credentials']['token']
      @user.story_user_id = auth_hash['uid']

      @user.save!

      auto_login(@user)
    end

    redirect_to '/'
  end

  def destroy
    logout
    redirect_to(:root, :notice => 'Logged out!')
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
