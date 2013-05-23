# encoding: utf-8
module ProfileTicket

  extend ActiveSupport::Concern
  
  def profile_name
    last_name + ' ' + first_name
  end
  
end