# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Seed Users
puts "Seeding Users..."
default_users = [
  { username: 'john_doe', email: 'john.doe@example.com', password: 'password123' },
  { username: 'jane_smith', email: 'jane.smith@example.com', password: 'password456' },
  { username: 'admin_user', email: 'admin@example.com', password: 'adminpassword' }
]

default_users.each do |user_data|
  User.find_or_create_by!(email: user_data[:email]) do |user|
    user.username = user_data[:username]
    user.password = user_data[:password] # Set password.  find_or_create_by! doesn't set this.
    puts "Created user: #{user.username} (#{user.email})"
  end
end

# Seed Posts
puts "\nSeeding Posts..."
user_john = User.find_by(username: 'john_doe')
user_jane = User.find_by(username: 'jane_smith')

if user_john && user_jane # Only create posts if these users exist.
  posts_data = []
  25.times do |i|
    user = i.even? ? user_john : user_jane # Alternate users
    posts_data << {
      title: "Post #{i + 1} by #{user.username}",
      body: "This is the content of post #{i + 1}.  It belongs to #{user.username}.",
      user: user,
      created_at: Faker::Time.between(from: 1.year.ago, to: Time.now) # Random date in the past year
    }
  end

  posts_data.each do |post_data|
    Post.find_or_create_by!(title: post_data[:title]) do |post| # changed to title
      post.body = post_data[:body]
      post.user = post_data[:user]
      post.created_at = post_data[:created_at] # set created_at
      puts "Created post: #{post.title} (Created at: #{post.created_at})"
    end
  end
else
  puts "WARNING: Users 'john_doe' and 'jane_smith' not found.  Posts not created."
end

# Seed Comments
puts "\nSeeding Comments..."

if User.any? && Post.any? # check if there are any User and Post
  posts = Post.all
  posts.each do |post|
    (2..3).to_a.sample.times do |i| # Randomly create 2-3 comments per post
      user = User.order("RANDOM()").first # Get random user.
      Comment.find_or_create_by(body: "Comment #{i+1} on #{post.title} by #{user.username}") do |comment|
        comment.user = user
        comment.post = post
        comment.created_at = Faker::Time.between(from: post.created_at, to: Time.now)
        puts "Created comment #{i+1} on Post: #{post.title} by User: #{user.username} (Created at: #{comment.created_at})"
      end
    end
  end
else
  puts "WARNING:  No Users or Posts found. Comments not created."
end

puts "\nSeeding complete!"
