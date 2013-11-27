class CustomerMailer < Devise::Mailer
  include AbstractController::Callbacks
  include SendGrid
  sendgrid_category :profile

  helper :application

  after_filter :save_instruction

  default :from => "Eviterra.com <profile@eviterra.com>", :reply_to => Conf.mail.profile_reply_to, :bcc => Conf.mail.profile_cc

  def first_purchase_instructions(record, opts={})
    @customer = record
    @format = 'first_purchase_instructions'
    devise_mail(record, :first_purchase_instructions, opts)
  end

  def invite_instructions(record, opts={})
    @customer = record
    @format = 'invite_instructions'
    devise_mail(record, :invite_instructions, opts)
  end

  def confirmation_instructions(record, opts={})
    @customer = record
    @format = 'confirmation_instructions'
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, opts={})
    @customer = record
    @format = 'reset_password_instructions'
    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, opts={})
    @customer = record
    @format = 'unlock_instructions'
    devise_mail(record, :unlock_instructions, opts)
  end

  def save_instruction
    if @customer
      instruction = CustomerInstruction.new(
        :customer_id => @customer.id,
        :status => 'sent',
        :email => @customer.email,
        :format => @format,
        :subject => message.subject,
        :message => message.body.raw_source
        )
        instruction.save
    end
  end

end
