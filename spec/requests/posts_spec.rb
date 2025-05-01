require 'rails_helper'

RSpec.describe "Posts API", type: :request do
  let!(:user) { FactoryBot.create(:user, email: 'user@example.com', password: 'password') }
  let!(:other_user) { FactoryBot.create(:user, email: 'user2@example.com', password: 'password2') }
  let!(:post) { FactoryBot.create(:post, user: user) }
  let!(:other_post) { FactoryBot.create(:post, user: other_user) }

  let(:headers) do
    token = JsonWebToken.encode(user_id: user.id)
    { 'Authorization' => "Bearer #{token}" }
  end

  describe "GET /posts" do
    it "returns all posts" do
      get "/posts"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
    end
  end

  describe "GET /posts/:id" do
    it "returns a single post" do
      get "/posts/#{post.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(post.id)
    end
  end

  # describe "POST /posts" do
  #   it "creates a post with valid token" do
  #     post "/posts", params: {
  #       post: { title: "New Post", body: "This is the content." }
  #     }, headers: headers

  #     expect(response).to have_http_status(:created)
  #     json = JSON.parse(response.body)
  #     expect(json["title"]).to eq("New Post")
  #   end

  #   it "returns unauthorized without token" do
  #     post "/posts", params: {
  #       post: { title: "No Auth", body: "Should fail." }
  #     }

  #     expect(response).to have_http_status(:unauthorized)
  #   end
  # end

  describe "PATCH /posts/:id" do
    it "updates own post" do
      patch "/posts/#{post.id}", params: {
        post: { title: "Updated Title" }
      }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['title']).to eq("Updated Title")
    end

    it "does not update someone else's post" do
      patch "/posts/#{other_post.id}", params: {
        post: { title: "Should Not Work" }
      }, headers: headers

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /posts/:id" do
    it "deletes own post" do
      delete "/posts/#{post.id}", headers: headers

      expect(response).to have_http_status(:no_content)
    end

    it "does not delete someone else's post" do
      delete "/posts/#{other_post.id}", headers: headers

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
