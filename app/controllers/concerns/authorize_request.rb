# app/controllers/concerns/authorize_request.rb
module AuthorizeRequest
  extend ActiveSupport::Concern

  included do
    before_action :authorize_request
  end

  def authorize_request
    header = request.headers['Authorization']
    if header.blank?
      render json: { errors: 'Authorization token missing' }, status: :unauthorized
      return
    end
    
    token = header.split(' ').last
    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded[:user_id])
      # Check if session is still valid
      session = @current_user.sessions.where(jti: token).first
      if @current_user.nil? || session.expired?
        render json: { errors: 'Session expired or invalid' }, status: :unauthorized
      end
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      render json: { errors: 'Unauthorized' }, status: :unauthorized
    end
  end
end
