# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include AuthorizeRequest

  before_action :authorize_request

  def show
    render json: @current_user
  end

  def update
    if @current_user.update(user_params)
      render json: @current_user
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_password
    if @current_user.authenticate(params[:current_password])
      if @current_user.update(password_params)
        render json: { message: 'Password updated successfully' }
      else
        render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Current password is incorrect' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :bio)
  end

  def password_params
    params.permit(:password, :password_confirmation)
  end
end
