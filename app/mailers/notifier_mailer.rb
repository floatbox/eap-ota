# encoding: utf-8
class NotifierMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :notification

  helper :pricer
  helper :booking
  helper :baggage
  helper :google_now
  helper :hotels
  helper :insurance
  helper :excursions
  layout 'pnr'

  add_template_helper(ApplicationHelper)
  default :from => "Eviterra.com <operator@eviterra.com>", :bcc => Conf.mail.ticket_cc

  def notice(notification)
    @comment = notification.comment
    @lang = notification.lang.presence

    if notification.attach_pnr
      @pnr = PNR.get_by_number(notification.pnr_number)
      @prices = @pnr.order
      @passengers = @pnr.passengers
      @last_pay_time = @pnr.order.last_pay_time
      
      notification.rendered_message = render 'pnr/' + notification.format
    else
      notification.rendered_message = render 'blank'
    end

    mail :to => notification.email, :subject => notification.subject do |format|
      format.html { render :text => notification.rendered_message }
    end
  end

  def booking_comment(pnr_number)
    render 'booking_notice', :locals => {:pnr_number => pnr_number}
  end

end
