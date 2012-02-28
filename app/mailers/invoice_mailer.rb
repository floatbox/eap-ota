class InvoiceMailer < ActionMailer::Base
  helper :pricer
  helper :booking

  add_template_helper(ApplicationHelper)
  default :from => "invoice@eviterra.com"

  def notice(order_id, comment = '')
    @order = Order.find(order_id)
    @pnr = PNR.get_by_number(@order.pnr_number)
    @mail_to = Conf.mail.invoice_to
    subject = "Invoice " + comment

    logger.info 'Invoice: sending email ' + @mail_to

    mail :to => @mail_to, :subject => subject do |format|
      format.text
    end
  end

end