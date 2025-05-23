# app/controllers/users_controller.rb
class UsersController < ApplicationController
  include AuthorizeRequest

  # @route GET /users/:id (user)
  # @route GET /profile
  def show
    render json: @current_user
  end

  # @route PATCH /users/:id (user)
  # @route PUT /users/:id (user)
  # @route PATCH /profile
  def update
    if @current_user.update(user_params)
      render json: @current_user
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # @route PATCH /profile/update_password (update_password)
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

  # @route GET /profile/posts
  def posts
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
  
    posts = @current_user.posts.includes(comments: :user)
                               .order(created_at: :desc)
                               .offset((page - 1) * per_page)
                               .limit(per_page)
  
    render json: {
      posts: posts.map do |post|
        {
          id: post.id,
          title: post.title,
          body: post.body,
          created_at: post.created_at,
          comment_count: post.comments.size,
          user_name: post.user.username
        }
      end
    }
  end

  private

  def user_params
    params.require(:user).permit(:username, :bio)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
