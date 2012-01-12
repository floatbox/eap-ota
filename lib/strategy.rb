# encoding: utf-8
# TODO изменить имя на что-то менее generic
module Strategy

  def self.select args={}
    source = args.delete(:source) || (args[:rec] || args[:order] || args[:ticket]).try(:source)
    case source
    when 'amadeus'
      Strategy::Amadeus.new args
    when 'sirena'
      Strategy::Sirena.new args
    else
      raise ArgumentError, (source ? 'unknown source #{source.inspect}' : 'source not specified')
    end

  end
end
