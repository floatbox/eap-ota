module Filter

  def self.make filter_symbol, arg
    if arg.is_a? Filter::Base
      arg
    else
      "Filter::#{filter_symbol.to_s.camelize}".constantize.new(arg)
    end
  end

  class Base
  end

  class Point < Base
    def initialize(location=nil)
      if Location::CLASSES.include?(location.class)
        @location = location
      else
        @location = Location.find_by_query(location)
      end
    end

    def airports
      case @location
      when nil
        []
      when *Location::CLASSES
        @location.airports
      else
        raise "unknown location type: #{@location.inspect}"
      end
    end

    def hash
      @location.hash
    end

    def as_json(options={})
      @location
    end
  end

  class From < Point
    def to_s
      if @location && @location.name
        @location.case_from
      else
        ''
      end
    end
  end

  class To < Point
    def to_s
      if @location && @location.name
        @location.case_to
      else
        ''
      end
    end
  end

  class Date < Base
    def initialize(*args)
      opts = args.extract_options!
      self.date1 = opts[:date1]
      self.date2 = opts[:date2]
    end

    attr_reader :date1, :date2

    def date1= arr
      @date1 = parse_dates arr
    end

    def date2= arr
      @date2 = parse_dates arr
    end

    # выводит год-месяц-число только если они не совпадают с текущим
    def to_s
      s = ''
      unless @date1.blank?
        d1 = @date1.first

        if @date2.blank?
          if d1.year == ::Date.today.year
            return I18n.l(d1, :format => '%e %B')
          else
            return I18n.l(d1, :format => '%e %B %Y')
          end

        else
          d2 = @date2.first

          if d1.year == d2.year
            if d1.month == d2.month
              f1, f2 = '%e', '%e %B'
            else
              f1, f2 = '%e %B', '%e %B'
            end

            if d1.year != ::Date.today.year
              f2 += ' %Y'
            end
          else
            f1, f2 = '%e %B %Y', '%e %B %Y'
          end

          return "с %s по %s" % [
            I18n.l(d1, :format => f1),
            I18n.l(d2, :format => f2)
          ]
        end
      end
    end

    def hash
      [date1, date2].hash
    end

    private

    def parse_dates arr
      arr = Array(arr)
      arr.map do |date_or_string|
        if date_or_string.is_a? ::Date
          date_or_string
        else
          ::Date.from_json date_or_string
        end
      end
    end
  end

  class Passenger < Base
    def initialize(count)
      @count = count.to_i
    end

    attr :count
    alias :to_i :count

    def as_json(options={})
      @count
    end

    def hash
      @count
    end
  end

  class Adults < Passenger
    def to_s
      unless @count.zero? || @count == 1
        "#{@count} " + Russian.p(@count, 'взрослый','взрослых','взрослых')
      else
        ''
      end
    end
  end

  class Children < Passenger
    def to_s
      unless @count.zero?
        "#{@count} " + Russian.p(@count, 'детский', 'детских', 'детских')
      else
        ''
      end
    end
  end

  class Classes < Base
    def initialize(type)
      @classes = type
    end

    def as_json(options={})
      @classes || 'any'
    end

    def to_s
      @classes
    end

    def hash
      @classes
    end
  end

  class Ret < Base
    def initialize(roundtrip)
      self.roundtrip = roundtrip.to_sym
    end

    attr_accessor :roundtrip

    def roundtrip?
      roundtrip == :rt
    end

    def oneway?
      roundtrip == :ow
    end

    def to_s
      roundtrip? ? 'и обратно' : ''
    end

    def as_json(options={})
      @roundtrip.to_s
    end

    def hash
      @roundtrip.hash
    end
  end

  class Mode < Base
    def initialize(mode)
      @mode = mode.to_sym
    end

    attr_accessor :mode

    def hotel?
      @mode == :hotel
    end

    def travel?
      @mode == :travel
    end

    def ticket?
      @mode == :ticket
    end

    def to_s
      case @mode
      when :ticket
        'билеты'
      when :hotel
        'отель'
      when :travel
        'билет+отель'
      end
    end

    def as_json(options={})
      @mode
    end

    def hash
      @mode.hash
    end
  end
end
