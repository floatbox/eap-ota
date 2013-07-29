# encoding: utf-8
#
# Все, что имеет отношение к админке закзов, и не используется больше нигде.
#
# FIXME потом попробовать перенсти вообще в декоратор/презентер
module TypusOrder

  extend ActiveSupport::Concern

  def to_label
    "#{source} #{pnr_number}"
  end

  def contact
    "#{email_searchable} #{phone}".html_safe
  end

  def contact_with_customer
    "#{email_searchable} #{phone} #{customer_link}".html_safe
  end

  #флаг для админки
  def urgent
    if  payment_status == 'blocked' && ticket_status == 'booked' &&
        ((last_tkt_date && last_tkt_date == Date.today) ||
         (departure_date && departure_date < Date.today + 3.days)
        )
      '<b>~ ! ~</b><br/>'.html_safe + ticket_time_decorated
    else
      ticket_time_decorated
    end
  end

  def ticket_time_decorated
#    if payment_status == 'blocked' && ticket_status == 'booked' && created_at > Date.yesterday + 20.5.hours
    if payment_status == 'blocked' && (ticket_status.in? 'booked', 'processing_ticket', 'error_ticket')
      now = DateTime.now
      date_to_ticket = ticket_datetime
      time_diff = ((date_to_ticket - now)/60).to_i
      if time_diff > 0
        time_diff = 180 if time_diff > 180
        time_diff_param = (time_diff.to_f*127/180).to_i
        rcolor = (255 - time_diff_param)
        gcolor = (time_diff_param)
        bcolor = 127
        color = "#%02X%02X%02X" % [rcolor, gcolor, gcolor]
      else
        color = "#ff0000; font-weight: bold";
      end
      "<span style='color:#{color};'>#{date_to_ticket.strftime('%H:%M')}</span><br/><abbr class='timeago' title='#{date_to_ticket}'>#{date_to_ticket}</abbr>".html_safe
    else
      '&nbsp;'.html_safe
    end
  end

  def ticket_datetime
    time = created_at.strftime('%H%M')
    case
      when time < '0600';  created_at.midnight + 11.hours
      when time < '0800';  created_at + 4.hours
      when time < '2030';  created_at + 3.hours
      else                 created_at.tomorrow.midnight + 11.hours
    end
  end

  def recalculation_alert
    if needs_recalculation
      "Суммы такс, сборов и скидок будут пересчитаны."
    else
      "Суммы такс, сборов и скидок НЕ будут пересчитаны, если заказ в состоянии 'ticketed'. Редактируйте каждый билет отдельно."
    end + ' ' +
      if fix_price
        "Итоговая стоимость не изменится при перерасчете, если закреплена 'Итоговая цена'"
      else
        "Итоговая стоимость будет пересчитана, если ее не закрепить или если поле пустое."
      end
  end

  def payment_type_decorated
    if payment_type != 'card'
      "<span style='color:firebrick; font-weight:bold'>#{payment_type}</span>".html_safe
    else
      "<span style='color:gray;'>#{payment_type}</span>".html_safe
    end
  end

  # FIXME отэскейпить емыл, воизбежание XSS
  def email_searchable
    "<a href='/admin/orders?search=#{email}'>#{email}</a>".html_safe
  end

  def customer_link
    if !customer_id.blank?
      "<a href='/admin/customers/show/#{customer_id}'>→<small>покупатель ##{customer_id}</small></a>".html_safe
    else
      "—"
    end
  end

  def parent_pnr_number_searchable
    if !parent_pnr_number.blank?
      "<a href='/admin/orders?search=#{parent_pnr_number}'>#{parent_pnr_number}</a>".html_safe
    elsif !pnr_number.blank?
      "<a href='/admin/orders?search=#{pnr_number}'>→<small>найти pnr number</small></a>".html_safe
    else
      "—"
    end
  end

end
