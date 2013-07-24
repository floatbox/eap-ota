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

  def password_required?
    super if confirmed?
  end

  def not_registred?
    !confirmation_sent_at
  end

  # TODO этот метод надо будет убрать при запуске ЛК
  # он отключает отсылку приглашения при создании кастомера
  def confirmation_required?
    !@skip_confirmation_notification
  end
  # этот метод уже рализован в devise но еще не выложен в gem
  # https://github.com/plataformatec/devise/commit/72cfaad6185332857cb5860a1d812f573efadaf7
  def skip_confirmation_notification!
    @skip_confirmation_notification = true
  end

  def pending_confirmation?
    confirmation_token.present?
  end

  def password_match?
    self.errors[:password] << "can't be blank" if password.blank?
    self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
    self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
    password == password_confirmation && !password.blank?
  end

end
