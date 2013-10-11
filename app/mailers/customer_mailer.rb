class CustomerMailer < Devise::Mailer
  include SendGrid
  sendgrid_category :profile

  helper :application

  default :from => "Eviterra.com <profile@eviterra.com>", :reply_to => Conf.mail.profile_reply_to, :bcc => Conf.mail.profile_cc

  def registration_instructions(record, opts={})
    devise_mail(record, :registration_instructions, opts)
  end

end
