# encoding: utf-8
module GoogleNowHelper
  def google_now_template(pnr, passengers)
    CustomTemplate.new.render(partial: 'pnr/google_now', locals: {pnr: pnr, passengers: passengers}).html_safe
  rescue
    ''
  end
end
