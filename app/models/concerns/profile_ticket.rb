# encoding: utf-8
module ProfileTicket

  extend ActiveSupport::Concern

  def profile_name
    last_name + ' ' + first_name
  end

  def profile_status
    return 'оформлен' if status == 'ticketed'
    return 'обменян' if status == 'exchanged'
    return 'возвращен' if status == 'returned'
  end

  def profile_active?
    kind == 'ticket' && status == 'ticketed'
  end

  def profile_alive?
    kind == 'ticket' && ['ticketed', 'exchanged'].include?(status)
  end

  def profile_returned?
    kind == 'ticket' && status == 'returned'
  end

  def profile_stored?
    flights.present?
  end

end