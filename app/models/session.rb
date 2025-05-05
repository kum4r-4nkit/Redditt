# app/models/session.rb
class Session < ApplicationRecord
  belongs_to :user

  validates :jti, presence: true, uniqueness: true

  def expired?
    expires_at < Time.current
  end
end