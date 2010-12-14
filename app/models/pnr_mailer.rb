class PnrMailer < ActionMailer::Base
  helper :pricer
  def pnr_notification(email, number)
    recipients email
    from       "eviterra@team.eviterra.ru"
    subject    "Ваш PNR"
    body(:pnr => Pnr.get_by_number(number))
  end

end
