# encoding: utf-8
class PNRMailer < ActionMailer::Base
  # FIXME Вместо него используется NotifierMailer
  helper :pricer
  helper :booking
  helper :baggage
  helper :google_now
  helper :hotels
  layout 'pnr'

  add_template_helper(ApplicationHelper)
  default :from => "Eviterra.com <operator@eviterra.com>", :bcc => Conf.mail.ticket_cc

  def notice(notification)
    @pnr = PNR.get_by_number(notification.pnr_number)
    @prices = @pnr.order
    @passengers = @pnr.passengers
    @last_pay_time = @pnr.order.last_pay_time
    @comment = notification.comment
    @lang = notification.lang unless notification.lang.blank?
    
    if notification.format.blank?
      notification.format = @pnr.order.show_as_ticketed? ? "ticket" : "booking"
    end
    
    notification.rendered_message = render 'pnr/blank' unless notification.attach_pnr

    case notification.format
      when 'ticket'
        notification.rendered_message = render 'pnr/ticket' if notification.attach_pnr
        if notification.subject.blank?
          notification.subject = @lang ? "Your E-ticket" : "Ваш электронный билет" 
        end
      when 'booking'
        notification.rendered_message = render 'pnr/booking' if notification.attach_pnr
        if notification.subject.blank?
          notification.subject = @lang ? "Your Booking" : "Ваше бронирование"
        end
    end

    mail :to => notification.email, :subject => notification.subject do |format|
      format.html { render :text => notification.rendered_message }
    end
  end

  def visa_notice
    mail :to => 'a@a.com', :subject => 'Информация о визе и адресе проживания в США' do |format|
      format.text { render 'notifications/visa_notice' }
    end
  end

end
