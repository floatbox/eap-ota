class CustomerMailer < Devise::Mailer
  helper :application

  default :from => "Eviterra.com <profile@eviterra.com>", :reply_to => Conf.mail.profile_reply_to, :bcc => Conf.mail.profile_cc

  def first_purchase_instructions(record, opts={})
    devise_mail(record, :first_purchase_instructions, opts)
  end

  def invite_instructions(record, opts={})
    devise_mail(record, :invite_instructions, opts)
  end

end
