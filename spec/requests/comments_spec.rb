require 'rails_helper'

RSpec.describe "Comments API", type: :request do
  let!(:user) { FactoryBot.create(:user, email: 'user@example.com', password: 'password') }
  let!(:user_post) { FactoryBot.create(:post, user: user) }
  let!(:comment) { create(:comment, post: user_post, user: user) }
  let!(:token) { JsonWebToken.encode(user_id: user.id) }
  let!(:session) { Session.create!(user: user, jti: token, expires_at: 24.hours.from_now) }

  let(:headers) do
    { 'Authorization' => "Bearer #{token}" }
  end

  # POST /posts/:post_id/comments
  describe 'POST /posts/:post_id/comments' do
    it 'creates a comment' do
      post "/posts/#{user_post.id}/comments", params: { comment: { body: 'New comment' } }, headers: headers

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['body']).to eq('New comment')
    end
  end

  # GET /posts/:post_id/comments/:id
  describe 'GET /posts/:post_id/comments/:id' do
    it 'returns a comment' do
      get "/posts/#{user_post.id}/comments/#{comment.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['body']).to eq(comment.body)
    end
  end

  # DELETE /posts/:post_id/comments/:id
  describe 'DELETE /posts/:post_id/comments/:id' do
    it 'deletes a comment' do
      delete "/posts/#{user_post.id}/comments/#{comment.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end
  end
end
