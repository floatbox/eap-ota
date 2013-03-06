# encoding: utf-8
module TypusCashCharge

  extend ActiveSupport::Concern

  def control_links
    refund_link if charged?
  end

  def refund_link
    "<a href='/admin/cash_refunds/new?_popup=true&resource[charge_id]=#{id}' class='iframe_with_page_reload'>добавить возврат</a>".html_safe
  end

end
