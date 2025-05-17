# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  include AuthorizeRequest

  before_action :set_post
  before_action :set_comment, only: [:show, :destroy]
  before_action :authorize_request, only: [:create, :destroy]

  # Create a comment for a post
  # @route POST /posts/:post_id/comments (post_comments)
  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = @current_user

    if @comment.save
      render json: @comment, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Show a comment
  # @route GET /posts/:post_id/comments/:id (post_comment)
  def show
    render json: @comment
  end

  # Destroy a comment
  # @route DELETE /posts/:post_id/comments/:id (post_comment)
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
