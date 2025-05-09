# Preview all emails at http://localhost:3000/rails/mailers/password_mailer/reset_password_email
class PasswordMailerPreview < ActionMailer::Preview
  def reset_password_email
    user = User.new(
      email: 'preview@example.com',
      reset_password_token: 'previewtoken123'
    )

    PasswordMailer.reset_password_email(user)
  end
end
