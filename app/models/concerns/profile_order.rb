# encoding: utf-8
module ProfileOrder

  extend ActiveSupport::Concern

  included do
    scope :profile_orders, where("pnr_number != ''").order("created_at DESC")
  end

  def profile_route
    route.blank? ? tickets.first.route : route
  end
  
  def profile_status
    payment_status + '/' + ticket_status
  end
  
  def profile_tickets
    rows = []
    if ticketed?
      tickets.each do |t|
        rows << {
          name: t.last_name + ' ' + t.first_name,
          status: t.status,
          number: t.number
        }
      end
    else
      infos = full_info.split
      infos.each do |t|
        data = t.split('/')
        rows << {
          name: data[1] + ' ' + data[0]
        }
      end
    end
    rows
  end
  
  def ticketed?
    tickets_count > 0
  end
  
end
