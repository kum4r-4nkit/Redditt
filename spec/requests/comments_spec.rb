# require 'rails_helper'

# RSpec.describe "Comments API", type: :request do
#   let!(:user) { FactoryBot.create(:user, email: 'user@example.com', password: 'password') }
#   let!(:post) { FactoryBot.create(:post, user: user) }
#   let!(:comment) { create(:comment, post: post, user: user) }

#   # POST /posts/:post_id/comments
#   describe 'POST /posts/:post_id/comments' do
#     context 'when the request is valid' do
#       it 'creates a comment' do
#         headers = { 'Authorization' => "Bearer #{user.auth_token}" }
#         post "/posts/#{post.id}/comments", params: { comment: { body: 'New comment' } }, headers: headers

#         expect(response).to have_http_status(:created)
#         json = JSON.parse(response.body)
#         expect(json['body']).to eq('New comment')
#       end
#     end

#     context 'when the request is invalid' do
#       it 'returns an error' do
#         headers = { 'Authorization' => "Bearer #{user.auth_token}" }
#         post "/posts/#{post.id}/comments", params: { comment: { body: '' } }, headers: headers

#         expect(response).to have_http_status(:unprocessable_entity)
#       end
#     end
#   end

#   # GET /posts/:post_id/comments/:id
#   describe 'GET /posts/:post_id/comments/:id' do
#     it 'returns a comment' do
#       get "/posts/#{post.id}/comments/#{comment.id}"

#       expect(response).to have_http_status(:ok)
#       json = JSON.parse(response.body)
#       expect(json['body']).to eq(comment.body)
#     end
#   end

#   # PATCH /posts/:post_id/comments/:id
#   describe 'PATCH /posts/:post_id/comments/:id' do
#     it 'updates a comment' do
#       headers = { 'Authorization' => "Bearer #{user.auth_token}" }
#       patch "/posts/#{post.id}/comments/#{comment.id}", params: { comment: { body: 'Updated comment' } }, headers: headers

#       expect(response).to have_http_status(:ok)
#       json = JSON.parse(response.body)
#       expect(json['body']).to eq('Updated comment')
#     end
#   end

#   # DELETE /posts/:post_id/comments/:id
#   describe 'DELETE /posts/:post_id/comments/:id' do
#     it 'deletes a comment' do
#       headers = { 'Authorization' => "Bearer #{user.auth_token}" }
#       delete "/posts/#{post.id}/comments/#{comment.id}", headers: headers

#       expect(response).to have_http_status(:no_content)
#     end
#   end
# end




































require 'rails_helper'

RSpec.describe "Comments API", type: :request do
  let!(:user) { FactoryBot.create(:user, email: 'user@example.com', password: 'password') }
  let!(:post) { FactoryBot.create(:post, user: user) }
  let!(:comment) { create(:comment, post: post, user: user) }

  # POST /posts/:post_id/comments
  describe 'POST /posts/:post_id/comments' do
    context 'when the request is valid' do
      it 'creates a comment' do
        # Sign up or login the user to obtain the token
        post '/login', params: { email: user.email, password: 'password' }
        token = JSON.parse(response.body)['token']  # Get token from response
        
        headers = { 'Authorization' => "Bearer #{token}" }
        post "/posts/#{post.id}/comments", params: { comment: { body: 'New comment' } }, headers: headers

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['body']).to eq('New comment')
      end
    end

    context 'when the request is invalid' do
      it 'returns an error' do
        # Sign up or login the user to obtain the token
        post '/login', params: { email: user.email, password: 'password' }
        token = JSON.parse(response.body)['token']  # Get token from response

        headers = { 'Authorization' => "Bearer #{token}" }
        post "/posts/#{post.id}/comments", params: { comment: { body: '' } }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  # GET /posts/:post_id/comments/:id
  describe 'GET /posts/:post_id/comments/:id' do
    it 'returns a comment' do
      get "/posts/#{post.id}/comments/#{comment.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['body']).to eq(comment.body)
    end
  end

  # PATCH /posts/:post_id/comments/:id
  describe 'PATCH /posts/:post_id/comments/:id' do
    it 'updates a comment' do
      # Sign up or login the user to obtain the token
      post '/login', params: { email: user.email, password: 'password' }
      token = JSON.parse(response.body)['token']  # Get token from response

      headers = { 'Authorization' => "Bearer #{token}" }
      patch "/posts/#{post.id}/comments/#{comment.id}", params: { comment: { body: 'Updated comment' } }, headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['body']).to eq('Updated comment')
    end
  end

  # DELETE /posts/:post_id/comments/:id
  describe 'DELETE /posts/:post_id/comments/:id' do
    it 'deletes a comment' do
      # Sign up or login the user to obtain the token
      post '/login', params: { email: user.email, password: 'password' }
      token = JSON.parse(response.body)['token']  # Get token from response

      headers = { 'Authorization' => "Bearer #{token}" }
      delete "/posts/#{post.id}/comments/#{comment.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end
  end
end
