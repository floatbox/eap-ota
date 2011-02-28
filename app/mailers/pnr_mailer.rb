# encoding: utf-8
class PnrMailer < ActionMailer::Base
  helper :pricer

  default :from => "Eviterra.com <ticket@eviterra.com>", :bcc => 'ticket@eviterra.com'

  def notification(email, number)
    @pnr = Pnr.get_by_number(number)
    mail :to => email, :subject => "Ваш электронный билет"
  end

end
