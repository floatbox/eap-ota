# encoding: utf-8
class PnrMailer < ActionMailer::Base
  helper :pricer
  helper :booking
  layout 'pnr'

  add_template_helper(ApplicationHelper)
  default :from => "Eviterra.com <ticket@eviterra.com>", :bcc => Conf.mail.ticket_cc

  def notice(notification)
    @pnr = PNR.get_by_number(notification.pnr_number)
    @prices = @pnr.order
    @passengers = @pnr.passengers
    @last_pay_time = @pnr.order.last_pay_time
    @comment = notification.comment

    if @pnr.order.show_as_ticketed?
      notification.rendered_message = render 'pnr/ticket'
    else
      notification.rendered_message = render 'pnr/booking'
    end

    if notification.subject.blank?
      notification.subject = @pnr.order.show_as_ticketed? ? "Ваш электронный билет" : "Ваше бронирование"
    end

    mail :to => notification.email, :subject => notification.subject do |format|
      format.html { render :text => notification.rendered_message }
    end
  end

  def sirena_receipt(email, number)
    @pnr = PNR.get_by_number(number)
    attachments['eticket.pdf'] = @pnr.sirena_receipt
    mail :to => email, :subject => "Ваш электронный билет"
  end

end
