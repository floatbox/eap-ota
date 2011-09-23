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
    
    if notification.format.blank?
      notification.format = @pnr.order.show_as_ticketed? ? "ticket" : "booking"
    end

    case notification.format
      when 'ticket'
        notification.rendered_message = render 'pnr/ticket'
        notification.subject = "Ваш электронный билет" if notification.subject.blank?
      when 'booking'
        notification.rendered_message = render 'pnr/booking'
        notification.subject = "Ваше бронирование" if notification.subject.blank?
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
