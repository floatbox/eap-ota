class Location

  CLASSES = [GeoTag, Country, City, Airport]

  def self.search *args
    opts = args.extract_options!
    args << opts.merge(:classes => CLASSES, :order => :importance, :sort_order => :desc)
    ThinkingSphinx.search(*args)
  end

  #private
  #def self.classess_option
  #  [Country, City, Airport]
  #end
  def self.find_by_query *args
    opts = args.extract_options!
    model = case opts[:kind]
            when 'geo_tag'
              GeoTag
            when 'city'
              City
            when 'airport'
              Airport
            when 'country'
              Country
            end
    if model
      model.find(opts[:id])
    end
  end

  def self.default
    # москва
    City.find_by_iata('MOW')
  end

  def self.quick_search(prefix)
    geo_tags = GeoTag.prefixed(prefix) #.limited(5)
    countries = Country.prefixed(prefix) #.limited(5)
    cities = City.prefixed(prefix) #.limited(5)
    airports = Airport.prefixed(prefix) #.limited(5)
    # убираем найденные аэропорты если город с тем же iata уже есть в выдаче
    cities_iatas = cities.map &:iata

    airports.reject! {|airport| cities_iatas.include? airport.iata }

    geo_tags + countries + cities + airports
  end

end
