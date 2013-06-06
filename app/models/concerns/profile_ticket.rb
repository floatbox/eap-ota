# encoding: utf-8
module ProfileTicket

  extend ActiveSupport::Concern

  def profile_name
    last_name + ' ' + first_name
  end

  def profile_status
    'оформлен'
  end

  def profile_alive?
    kind ='ticket' && ['ticketed', 'exchanged'].include?(status)
  end

end