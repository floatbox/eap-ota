# encoding: utf-8
module TypusPaytureCharge

  include ActiveSupport::Concern

  # FIXME надо бы убрать вызов gateway отсюда
  def payment_status_raw
    response = gateway.status(:our_ref => ref)
    response.err_code || "#{response.status}: #{response.amount} (#{PaytureCharge::STATUS_MAPPING[response.status] || 'unknown'})"
  rescue
    $!.message
  end

  def control_links
    refund_link if charged?
  end

  def refund_link
    "<a href='/admin/payture_refunds/new?_popup=true&resource[charge_id]=#{id}' class='iframe_with_page_reload'>добавить возврат</a>".html_safe
  end

  def external_gateway_link
    url = "https://backend.payture.com/Payture/order.html?mid=55&pid=&id=#{ref}"
    "<a href='#{url}' target='_blank'>OrderId: #{ref}</a>".html_safe
  end

  def error_explanation
    Payture::ERRORS_EXPLAINED[error_code] || error_code
  end
end
