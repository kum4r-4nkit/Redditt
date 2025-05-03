# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  include AuthorizeRequest

  before_action :authorize_request, except: [:index, :show]  # Or remove `except:` to protect all
  before_action :set_post, only: [:show, :update, :destroy]

  def index
    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
  
    total_count = Post.count
    total_pages = (total_count.to_f / per_page).ceil
  
    posts = Post.includes(:user, comments: :user)
                .order(created_at: :desc)
                .offset((page - 1) * per_page)
                .limit(per_page)
  
    render json: {
      posts: ActiveModelSerializers::SerializableResource.new(posts),
      meta: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: total_pages
      }
    }
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
