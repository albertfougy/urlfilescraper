require 'action_mailer'
require 'active_support'

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'gmail.com',
    :user_name => 'mygmailaddress',
    :password => 'app_password_given_by_gmail',
    :authentication => :plain,
    enable_starttls_auto: true
}

class SimpleMailer < ActionMailer::Base
  def simple_message(recipient, subject, message)
    mail(:from => 'sendersgmailaddress',
         :to => recipient,
         :subject => subject,
         :body => message)
  end
end
