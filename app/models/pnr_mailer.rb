class PnrMailer < ActionMailer::Base
  def pnr_notification(email, number)
    recipients email
    from       "eviterra@team.eviterra.ru"
    subject    "Новый pnr"
    body       "Уважаемый, вот ваш PNR: http://gamma.team.eviterra.ru/pnr_form/#{number}"
  end

end
