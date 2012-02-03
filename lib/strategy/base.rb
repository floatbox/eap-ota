# encoding: utf-8
class Strategy::Base

  include KeyValueInit

  attr_accessor :rec, :search, :order, :ticket, :order_form

  cattr_accessor :dropped_recommendations_logger do
    ActiveSupport::BufferedLogger.new(Rails.root + 'log/dropped_recommendations.log')
  end

  cattr_accessor :logger do
    Rails.logger
  end

  attr_writer :source
  def source
    @source || @rec.try(:source) || @order.try(:source)
  end

  # preliminary booking
  # ###################

  def check_price_and_availability
    raise NotImplementedError
  end

  # booking
  # #######

  def create_booking
    raise NotImplementedError
  end

  # canceling
  # ########

  def cancel
    raise NotImplementedError
  end

  def void
    raise NotImplementedError
  end

  # get tickets hashes
  # ########

  def get_tickets_and_dept_date
    raise NotImplementedError
  end

  # ticketing
  # #########

  def delayed_ticketing?
    raise NotImplementedError
  end

  def ticket
    raise NotImplementedError
  end

  # debug view
  ############

  def raw_pnr
    raise NotImplementedError
  end

  def raw_ticket
    raise NotImplementedError
  end

  def flight_from_gds_code *args
    raise NotImplementedError
  end
end

