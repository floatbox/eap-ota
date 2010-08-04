class FlightQuery

  def initialize query
    self.attributes = query.slice(:to, :from, :date, :adults, :children, :sort, :classes, :ret, :mode)
    if text = (query[:to] && query[:to][:text])
      QueryParser.parse(self, text)
    end
  end

  attr_reader :from, :to, :date, :adults, :children, :sort, :classes, :ret, :mode

  def from= args
    @from = Filter.make :from, args
    #@from.update args
  end

  def to= args
    @to = Filter.make :to, args
    #@to.update args
  end

  def date= args
    @date = Filter.make :date, args
    #@date.update args
  end

  def adults= args
    @adults = Filter.make :adults, args
  end

  def children= args
    @children = Filter.make :children, args
  end

  def classes= args
    @classes = Filter.make :classes, args
  end

  def sort= column
    @sort = column
  end

  def ret= args
    @ret = Filter.make :ret, args
  end

  def mode= args
    @mode = Filter.make :mode, args
  end

  def results
    return @results if @results
    return [] unless valid?
    args = {}
    args[:from] = from.airports.first.try(:city).try(:iata)
    args[:to] = to.airports.first.try(:city).try(:iata)
    args[:adults] = adults.to_i
    args[:children] = children.to_i

    begin
      args[:date1] = date.date1.first.strftime( '%d%m%y' )
      args[:date2] = date.date2.first.strftime( '%d%m%y' )
    rescue
    end
    @search = PricerForm.new(args)
  end

  def stats
    layovers = results.map {|o| o.layovers }.uniq.sort.map do |l|
      name = {0 => "без пересадок", 1 => "одна пересадка", 2 => "две пересадки"}[l]
      {:id => l, :name => name}
    end

    {
      :companies => results.every.company.compact.uniq.sort_by(&:name),
      :cities => results.map {|o| o.city}.uniq.sort_by(&:name),
      :countries => results.map {|o| o.country}.uniq.sort_by(&:name),
      :hotels => results.map {|o| o.hotel}.compact.uniq.sort_by(&:name),
      :hotel_stars => hotel_stars,
      :hotel_distances_to_airport => results.map {|o| o.hotel.try(:distance_to_airport) }.compact.minmax,
      :hotel_distances_to_center => results.map {|o| o.hotel.try(:distance_to_center) }.compact.minmax,
      :hotel_features => hotel_features,
      :hotel_prices => results.map {|o| o.hotel_price.value}.minmax,
      :flight_prices => results.map {|o| o.flight_price.value}.minmax,
      :layovers => layovers,
      :prices => results.map {|o| o.price.value}.minmax
    }.delete_if {|k,v| v.blank? }
  end

  def valid?
    from && to && date && !date.date1.blank?
  end

  def as_json(options = {})
    filled_attributes.merge :humanized => humanized, :hash => hash
  end

  def attributes
    { :from => from,
      :to => to,
      :date => date,
      :adults => adults,
      :children => children,
      :ret => ret,
      :mode => mode,
      :classes => classes
    }
  end

  def filled_attributes
    attributes.reject {|k,v| v.blank?}
  end

  def update(other)
    self.attributes = other.filled_attributes
  end


  def to_s
    #"#{from} #{to} #{date} #{adults} #{children}"
    [from, to, date, adults, children].map(&:to_s).delete_if(&:blank?).join(' ')
  end

  def hash
    [from, to, date, ret].hash
  end
end
