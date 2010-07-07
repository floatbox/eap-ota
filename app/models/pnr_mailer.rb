class PnrMailer < ActionMailer::Base
  def pnr_notification(pnr_form, number)
    recipients pnr_form.email
    from       "eviterra@team.eviterra.ru"
    subject    "Новый pnr"
    body       "Уважаемый #{pnr_form.first_name} #{pnr_form.surname}, вот ваш PNR: http://gamma.team.eviterra.ru/pnr_form/#{number}"
  end

end
