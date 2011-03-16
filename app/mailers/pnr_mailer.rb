# encoding: utf-8
class PnrMailer < ActionMailer::Base
  helper :pricer

  default :from => "Eviterra.com <ticket@eviterra.com>", :bcc => Conf.mail.ticket_cc

  def notification(email, number)
    @pnr = Pnr.get_by_number(number)
    mail :to => email, :subject => "Ваш электронный билет"
  end

end
