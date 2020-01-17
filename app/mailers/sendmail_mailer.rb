class SendmailMailer < ApplicationMailer
  def email_notification(message)
    @errorMessage = message
    mail from: 'kbs4674@damda.info',
    to: "#{ENV['ADMIN_LIST']}",
    subject: "캐치딜 서비스 기능불능 경고안내",
    html: render(template: "sendmail_mailer/email_notification")
  end
end
