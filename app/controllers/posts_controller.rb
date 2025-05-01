# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include AuthorizeRequest

  before_action :authorize_request, except: [:index, :show]  # Or remove `except:` to protect all
  before_action :set_post, only: [:show, :update, :destroy]


  def index
    posts = Post.includes(:user, :comments).all
    render json: posts.as_json(include: [:user, :comments])
  end

  def show
    render json: @post.as_json(include: [:user, :comments])
  end

  def create
    post = @current_user.posts.build(post_params)

    if post.save
      render json: post, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @post.user_id != @current_user.id
      render json: { error: "Not authorized" }, status: :unauthorized
      return
    end
  
    if @post.update(post_params)
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  def destroy
    if @post.user_id != @current_user.id
      render json: { error: "Not authorized" }, status: :unauthorized
      return
    end

    @post.destroy!
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params.expect(:id))
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
