require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /signup' do
    let(:valid_attributes) do
      {
        username: 'testuser',
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      }
    end

    it 'creates a new user and returns a token' do
      post '/signup', params: valid_attributes

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to have_key('token')
    end

    it 'returns error for mismatched password confirmation' do
      invalid_attributes = valid_attributes.merge(password_confirmation: 'wrongpass')

      post '/signup', params: invalid_attributes

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'POST /login' do
    let!(:user) { FactoryBot.create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

    it 'authenticates user and returns a token' do
      post '/login', params: { email: 'test@example.com', password: 'password123' }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('token')
    end

    it 'returns unauthorized for invalid credentials' do
      post '/login', params: { email: 'test@example.com', password: 'wrongpass' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
