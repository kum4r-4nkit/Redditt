# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include AuthorizeRequest
  before_action :set_post, only: [:show, :update]

  # @route GET /posts (posts)
  def index
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
  
    posts = Post.includes(:user, comments: :user)
                .order(created_at: :desc)
                .offset((page - 1) * per_page)
                .limit(per_page)

    render json: {
      posts: posts.map do |post|
        {
          id: post.id,
          title: post.title,
          body: post.body.truncate(150),
          created_at: post.created_at,
          comment_count: post.comments.size
        }
      end
    }
  end

  # @route GET /posts/:id (post)
  def show
    render json: @post, include: ['user', 'comments.user']
  end

  # @route POST /posts (posts)
  def create
    post = @current_user.posts.build(post_params)

    if post.save
      render json: post, status: :created
    else
      render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # @route PATCH /posts/:id (post)
  # @route PUT /posts/:id (post)
  def update
    if @post.user_id != @current_user.id
      render json: { error: "Not authorized" }, status: :unauthorized
      return
    end
  
    if @post.update(post_params)
      render json: @post, include: ['user', 'comments.user']
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # @route DELETE /posts/:id (post)
  def destroy
    post = Post.find(params.expect(:id))
    if post.user_id != @current_user.id
      render json: { error: "Not authorized" }, status: :unauthorized
      return
    end

    post.destroy!
    head :no_content
  end

  private

  def set_post
    @post = Post.includes(:user, comments: :user).find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
