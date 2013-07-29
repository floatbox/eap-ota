class CustomerMailer < Devise::Mailer
  helper :application

  default :from => "Eviterra.com <profile@eviterra.com>", :reply_to => Conf.mail.profile_reply_to, :bcc => Conf.mail.profile_cc

end
