class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :created_at, :parent_id, :replies

  belongs_to :user

  def replies
    object.replies.map do |reply|
      CommentSerializer.new(reply, scope: scope, root: false).as_json
    end
  end
end
