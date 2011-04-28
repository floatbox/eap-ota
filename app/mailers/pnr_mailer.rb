# encoding: utf-8
class PnrMailer < ActionMailer::Base
  helper :pricer
  helper :booking

  default :from => "Eviterra.com <ticket@eviterra.com>", :bcc => Conf.mail.ticket_cc

  def notification(email, number)
    @pnr = Pnr.get_by_number(number)
    mail :to => email, :subject => @pnr.order.payment_type == 'card' ? "Ваш электронный билет" : "Ваше бронирование"
  end

  def sirena_receipt(email, number)
    @pnr = Pnr.get_by_number(number)
    attachments['eticket.pdf'] = @pnr.sirena_receipt
    mail :to => email, :subject => "Ваш электронный билет"
  end

end
