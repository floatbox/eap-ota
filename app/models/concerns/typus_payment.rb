# encoding: utf-8
module TypusPayment

  extend ActiveSupport::Concern

  # для админки
  def to_label
    "#{I18n.t type} ##{id} #{'%.2f' % price} р. #{payment_status}"
  end

  # TODO override in subclasses
  def payment_status_raw
    "--"
  end

  def error_explanation
  end

  def show_link
    title = "#{I18n.t type} ##{id}"
    "<a href='/admin/payments/show/#{id}'>#{title}</a>".html_safe
  end

  # оверрайдить в субклассах-рефандах
  def charge_link
  end

  def external_gateway_link
  end

  def payment_info
    "#{pan_searchable} #{name_in_card}".html_safe if pan.present? || name_in_card.present?
  end

  def control_links
    ''
  end

  def status_decorated
    if secured?
      "<span style='color:green; font-weight:bold'>#{status}</span>".html_safe
    else
      "<span style='color:gray;'>#{status}</span>".html_safe
    end
  end

  # FIXME устранить XSS
  def pan_searchable
    "<a href='/admin/payments?search=#{pan}'>#{pan}</a>".html_safe
  end

end
