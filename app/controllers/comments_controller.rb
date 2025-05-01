# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :authorize_request, only: [:create, :update, :destroy]

  # Create a comment for a post
  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      render json: @comment, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Show a comment
  def show
    render json: @comment
  end

  # Update a comment
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Destroy a comment
  def destroy
    @comment.destroy
    head :no_content
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
