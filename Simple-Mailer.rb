require 'action_mailer'
require 'active_support'

ActionMailer::Base.smtp_settings = {
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'gmail.com',
    :user_name => 'alfougy@gmail.com',
    :password => 'uzueoyzmlbbiyoam',
    :authentication => :plain,
    enable_starttls_auto: true
}

class SimpleMailer < ActionMailer::Base
  def simple_message(recipient, subject, message)
    mail(:from => 'alfougy@gmail.com',
         :to => recipient,
         :subject => subject,
         :body => message)
  end
end