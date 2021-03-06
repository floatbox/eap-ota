# encoding: utf-8
# TODO изменить имя на что-то менее generic
module Strategy

  class Error < StandardError
  end

  class TicketError < Error
  end

  def self.select args={}
    source = args.delete(:source) || (args[:rec] || args[:order] || args[:ticket]).try(:source)
    case source
    when 'amadeus'
      Amadeus::Strategy.new args
    else
      raise ArgumentError, (source ? "unknown source #{source.inspect}" : 'source not specified')
    end

  end
end
