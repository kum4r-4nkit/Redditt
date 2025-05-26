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

    if user.locked_until && user.locked_until > Time.current
      render json: { error: "Account is temporarily locked. Try again later." }, status: :unauthorized
      return
    end
    
    if user&.authenticate(params[:password])
      user.update(failed_attempts: 0, locked_until: nil)
      token = JsonWebToken.encode(user_id: user.id)
      Session.create!(user: user, jti: token, expires_at: 24.hours.from_now)
      render json: { token: token }, status: :ok
    else
      user.increment!(:failed_attempts)
      if user.failed_attempts >= 5
        user.update(locked_until: 120.minutes.from_now)
        render json: { error: "Account locked due to multiple failed attempts. Try again in 2 hours." }, status: :unauthorized
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
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
