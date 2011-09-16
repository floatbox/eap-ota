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
      content = render 'pnr/ticket'
    else
      content = render 'pnr/booking'
    end
    save_notice(content, notification.id)

    mail :to => notification.email, :subject => @pnr.order.show_as_ticketed? ? "Ваш электронный билет" : "Ваше бронирование" do |format|
      format.html { render :text => content }
    end
  end

  def save_notice(content, id)
    path = Rails.root + 'log/notice/' + "#{id}.html"
    File.open(path, 'w') {|f| f.write(content) }
  end

  def sirena_receipt(email, number)
    @pnr = PNR.get_by_number(number)
    attachments['eticket.pdf'] = @pnr.sirena_receipt
    mail :to => email, :subject => "Ваш электронный билет"
  end

end
