# app/controllers/passwords_controller.rb
class PasswordsController < ApplicationController
  def forgot
    user = User.find_by(email: params[:email])

    if user
      user.reset_password_token = SecureRandom.hex(10)
      user.reset_password_sent_at = Time.current
      user.save!

      PasswordMailer.reset_password_email(user).deliver_later
      render json: { message: 'Reset instructions sent.' }
    else
      render json: { error: 'Email not found' }, status: :not_found
    end
  end

  def reset
    user = User.find_by(reset_password_token: params[:token])

    if user && user.reset_password_sent_at > 15.minutes.ago
      if user.update(password_params.merge(reset_password_token: nil, reset_password_sent_at: nil))
        render json: { message: 'Password has been reset.' }
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
