class PnrMailer < ActionMailer::Base
  helper :pricer
  def pnr_notification(email, number)
    recipients email
    from       "Eviterra.com <ticket@eviterra.com>"
    subject    "Ваш электронный билет"
    body(:pnr => Pnr.get_by_number(number))
  end

end
