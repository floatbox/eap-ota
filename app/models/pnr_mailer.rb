class PnrMailer < ActionMailer::Base
  helper :pricer
  def pnr_notification(email, number)
    recipients email
    from       "no-reply@eviterra.com"
    reply_to   "ticket@eviterra.com"
    subject    "Ваш PNR"
    body(:pnr => Pnr.get_by_number(number))
  end

end
