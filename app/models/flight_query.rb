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
    # args[:nonstop] = ?  
    args[:rt] = ( ret && ret.roundtrip?)
    # args[:search_type] || 'travel'
    args[:debug] = true if mode.try(:ticket?)
    @search = PricerForm.new(args)
    return [] unless @search.valid?
    @results = @search.search_offers
  end

  # чертовски рандомный календарег
  def calendar
    if from
      startdate = date && date.date1.first || Date.today
      (startdate..(startdate+30.days)).inject({}) do |hash,d|
        p = Price.new((5000..10000).random)
        # ааа!! стрелочки!!!
        p.mode = ['back','forth'].random
        hash[d.strftime('%m/%d/%Y')] = p
        hash
      end
    else
      {}
    end
  end

  def stats
    layovers = results.map {|o| o.layovers }.uniq.sort.map do |l|
      name = {0 => "без пересадок", 1 => "одна пересадка", 2 => "две пересадки"}[l]
      {:id => l, :name => name}
    end

    hotels = results.map(&:hotel).compact
    hotel_stars = hotels.map(&:stars).uniq.sort.map do |s|
      name = {2 => 'две звезды', 3 => 'три звезды', 4 => 'четыре звезды', 5 => 'пять звезд'}[s]
      {:id => s, :name => name}
    end
    hotel_features = hotels.map(&:features).flatten.uniq.sort.map do |f|
      {:id => f, :name => f}
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
    attributes.delete_if {|k,v| v.blank?}
  end

  def attributes=(attrs)
    attrs.each do |k, v|
      send "#{k}=", v
    end
  end

  def update(other)
    self.attributes = other.filled_attributes
  end

  def self.random
    query = new(
      :from => City.random,
      :to => City.random
    )
    random_date = Date.today + rand(10).days
    query.date = {
      :date1 => [random_date],
      :date2 => [random_date + rand(10).days]
    }
    query
  end

  def humanized
    result = {}
    attributes.each do |method, value|
      next if value.blank?
      result[method] = value.to_s
    end
    result
  end

  def to_s
    #"#{from} #{to} #{date} #{adults} #{children}"
    [from, to, date, adults, children].map(&:to_s).delete_if(&:blank?).join(' ')
  end

  def hash
    [from, to, date, ret].hash
  end
end
