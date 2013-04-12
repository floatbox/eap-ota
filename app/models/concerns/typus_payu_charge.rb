# encoding: utf-8
module TypusPayuCharge

  extend ActiveSupport::Concern

  # FIXME надо бы убрать вызов gateway отсюда, ему место в модели

  def payment_status_raw
    response = gateway.status(:our_ref => ref)
    response.err_code || "#{response.status}: (#{STATUS_MAPPING[response.status] || 'unknown'})"
  rescue
    $!.message
  end

  def control_links
    refund_link if charged?
  end

  def refund_link
    "<a href='/admin/payu_refunds/new?_popup=true&resource[charge_id]=#{id}' class='iframe_with_page_reload'>добавить возврат</a>".html_safe
  end

  def external_gateway_link
    url = "https://secure.payu.ru/cpanel/reports.php?interval=lastYear&seekFor=#{ref}&seekIn=externalrefno&status=all&Submit=DoIT"
    "<a href='#{url}' target='_blank'>Reference: #{their_ref}</a>".html_safe
  end

  def error_explanation
    [ ERRORS_EXPLAINED[error_code] || error_code, error_message ].compact.join(': ')
  end

  ERRORS_EXPLAINED = {
    '1' => 'Confirmed.',                             # (заказ подтвержден)
    '2' => 'ORDER_REF missing or incorrect',         # (Неверный или пустой номер заказа)
    '3' => 'ORDER_AMOUNT missing or incorrect',      # (Неверная или пустая итоговая сумма заказа)
    '4' => 'ORDER_CURRENCY is missing or incorrect', # (Неверная или пустая валюта заказа)
    '5' => 'IDN_DATE is not in the correct format',  # (Некорректный формат IDN_DATE)
    '6' => 'Error confirming order',                 # (Ошибка подтверждения заказа)
    '7' => 'Order already confirmed',                # (Заказ уже был подтверждён)
    '8' => 'Unknown error',                          # (Неизвестная ошибка)
    '9' => 'Invalid ORDER_REF',                      # (Неверный номер заказа)
    '10' => 'Invalid ORDER_AMOUNT',                  # (Неверная итоговая сумма заказа)
    '11' => 'Invalid ORDER_CURRENCY'                 # (Неверная валюта заказа)
  }

end
