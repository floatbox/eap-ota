class Hotel

  include KeyValueInit

  def self.random opts
    stars = (3..5).random
    price = (500..1000).random * stars

    hotel = new( {
      :name => NAMES.random,
      :stars => stars,
      :price => price,
      :description => DESCRIPTIONS.random,
      :address => ADDRESSES.random,
      :features =>  (1 .. (5..10).random).map { FEATURES.random }.uniq,
      }.merge(opts.slice(:name, :stars, :price, :city, :description, :features))
    )

    if city = opts[:city]
      radius = 0.02
      hotel.lat = city.lat - radius + rand*2*radius
      hotel.lng = city.lng - radius + rand*2*radius
      hotel.distance_to_center = calculate_distance( city, hotel )
      if airport = opts[:airport]
        hotel.distance_to_airport = calculate_distance( airport, hotel )
      end
    end

    hotel
  end

  attr_accessor :id, :name, :stars, :price, :city, :description, :features, :lat, :lng, :distance_to_center, :distance_to_airport, :address

  def latitude; lat end
  def longitude; lng end

  def price= price
    @price = Price.new(price)
  end

  def self.calculate_distance from, to
    Graticule::Distance::Vincenty.distance(from, to, :kilometers)
  end

  NAMES = <<-"END".lines.map(&:strip)
    Aston Resort & Spa
    InterContinental Resort
    The Mansion
    The Vira Hotel
    Holiday Inn
    Le Meridien Golf & Spa
    Best Western
    Grand Hyatt
    Alila Villas
    Comfort Inn
    Renaissance Grand Hotel
    Marriott Hotel & Conference Center
    Evergreen Laurel Hotel
    Hotel Residence Romance
    Radisson Royal Blu Hotel
    Novotel Convention & Wellness
    Sheraton Airport Hotel & Conference Centre
    Hibiscus
    Amadeus Hotel
    Royal Regency
  END

  DESCRIPTIONS = <<-"END".lines.map(&:strip)
    Идеальный вариант экономного пребывания в городе. Отель расположен на тихой улице в деловом и артистическом центре, недалеко от больших магазинов.
    Известный фешенебельный отель объединяет в себе атмосферу частного отеля, величественный декор периода Второй Империи и современный комфорт. Отель находится в культурном и деловом центре города и очень выгодно расположен по отношению к достопримечательностям и магазинам.
    Типично классический архитектурный стиль гостиницы создает утонченную атмосферу уюта, идеально подходящую для отдыха с семьей или друзьями. В 2007 году гостиница была полностью обновлена.
    Отель находится в одном из центральных районов и входит в уникальный архитектурный ансамбль, занесенный в список исторических памятников города. Гостиница занимает здание постройки XIX века, рядом разбит сад.
    Современный отель с прекрасными номерами и хорошим уровнем обслуживания. Расположен в историческом центре города и предлагает номера с живописными видами.
  END

  FEATURES = <<-"END".lines.map(&:strip)
    автостоянка
    ресторан
    бар
    номера для некурящих
    бесплатная парковка
    сейф
    кондиционер
    теннисный корт
    сауна
    фитнес-центр
    спа и оздоровительный центр
    детская игровая площадка
    бассейн
    конференц-зал
    wi-fi
    прокат автомобилей
    банкомат
    химчистка
  END

  ADDRESSES = <<-"END".lines.map(&:strip)
    1st Tverskaya Yamskaya Street 19
    3/6 Build.1 Rozhdestvenka Str
    158 Leninsky prospect
    71 Izmailovskoye Highway
    811 7th Avenue 53rd Street
    511 Lexington Avenue
    150 East 34th Street (Midtown East)
  END
end
