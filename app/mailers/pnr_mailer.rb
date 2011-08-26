# encoding: utf-8
class PnrMailer < ActionMailer::Base
  helper :pricer
  helper :booking

  add_template_helper(ApplicationHelper)
  default :from => "Eviterra.com <ticket@eviterra.com>", :bcc => Conf.mail.ticket_cc

  def notification(email, number)
    @pnr = PNR.get_by_number(number)
    @prices = @pnr.order
    @passengers = @pnr.passengers
    @last_pay_time = @pnr.order.last_pay_time
    mail :to => email, :subject => @pnr.order.show_as_ticketed? ? "Ваш электронный билет" : "Ваше бронирование"
    if @pnr.order.show_as_ticketed?
      render 'pnr/ticket'
    else
      render 'pnr/booking'
    end
  end

  def sirena_receipt(email, number)
    @pnr = PNR.get_by_number(number)
    attachments['eticket.pdf'] = @pnr.sirena_receipt
    mail :to => email, :subject => "Ваш электронный билет"
  end

end
