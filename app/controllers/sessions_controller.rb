class SessionsController < ApplicationController
  skip_before_action :login_required, only: [:new, :create]
  def new
    if current_user!=nil
      redirect_to tasks_path
    end
  end
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      redirect_to user_path(user.id)
    else
      flash.now[:danger] = 'failed to login'
      render :new
    end
  end
  def destroy
    session.delete(:user_id)
    flash[:notice] = 'logged out'
    redirect_to new_session_path
  end

end