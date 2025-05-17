class AuthController < ApplicationController
  # @route POST /signup (signup)
  def signup
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id)
      Session.create!(user: user, jti: token, expires_at: 24.hours.from_now)
      render json: { token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # @route POST /login (login)
  def login
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      Session.create!(user: user, jti: token, expires_at: 24.hours.from_now)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  # @route POST /logout (logout)
  def logout
    token = request.headers['Authorization']&.split&.last
    active_token = Session.find_by(jti: token)
    active_token&.destroy
    head :no_content
  end

  private

  def user_params
    params.permit(:username, :email, :password, :password_confirmation)
  end
end
