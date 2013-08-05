# encoding: utf-8
class Customer < ActiveRecord::Base

  include TypusCustomer

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable, :validatable
  devise :database_authenticatable, :registerable, :validatable,
          :confirmable,
          :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_paper_trail

  has_many :orders

  def cancel_confirmation!
      self.confirmation_token = nil
      self.confirmation_sent_at = nil
      self.confirmed_at = nil
      self.last_sign_in_at = nil
      save
  end

  def password_required?
    super if confirmed?
  end

  def not_registred?
    !confirmation_sent_at
  end

  def pending_confirmation?
    confirmation_token.present?
  end

  # Send confirmation instructions by email
  def send_registration_instructions
    self.confirmation_token = nil if reconfirmation_required?
    @reconfirmation_required = false

    generate_confirmation_token! if self.confirmation_token.blank?

    opts = pending_reconfirmation? ? { :to => unconfirmed_email } : { }
    send_devise_notification(:registration_instructions, opts)
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

end
