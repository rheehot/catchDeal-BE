# Preview all emails at http://localhost:3000/rails/mailers/sendmail_mailer
class SendmailMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/sendmail_mailer/email_notification
  def email_notification
    SendmailMailer.email_notification
  end

end
