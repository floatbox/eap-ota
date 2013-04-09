# encoding: utf-8
module Completer
  class DbReader

    def initialize(completer)
      @completer = completer
    end

    def add(args)
      @completer.add(args)
    end

    # наполняет и возвращает комплитер
    def read
      important =
        (
          Country.important.all +
          City.important.with_country.all +
          Airport.important.with_country.all
        ).sort_by(&:importance).reverse
      lists =
        [
          important,
          Country.not_important,
          City.not_important.with_country,
          Airport.not_important.with_country
        ]
      lists.each do |list|
        list.each do |c|
          add_object(c)
        end
      end
      @completer
    end

    def add_object(obj)
      case obj
      when Country
        add_country(obj)
      when City
        add_city(obj)
      when Airport
        add_airport(obj)
      end
    end

  end

  class DbReaderEn < DbReader
    def add_country(c)
      # TODO сделать континенты для английского комплитера
      add(:name => c.name_en, :type => 'country', :code => c.iata, :hint => '') # :hint => c.continent_part_ru)
    end

    def add_city(c)
      add(:name => c.name_en, :type => 'city', :code => c.iata, :hint => c.country.name_en)
    end

    def add_airport(c)
      return if c.equal_to_city
      add(:name => c.name_en, :type => 'airport', :code => c.iata, :hint => c.city.name_en)
    end
  end

  class DbReaderRu < DbReader
    def add_country(c)
      add(:name => c.name, :type => 'country', :code => c.iata, :aliases => [c.name_en, c.synonyms], :hint => c.continent_part_ru)
      add(:name => c.case_to, :type => 'country', :code => c.iata, :hint => c.continent_part_ru)
    end

    def add_city(c)
      add(:name => c.name, :type => 'city', :code => c.iata, :aliases => [c.name_en, c.synonyms], :hint => c.country.name)
      add(:name => c.case_to, :type => 'city', :code => c.iata, :hint => c.country.name)
    end

    def add_airport(c)
      return if c.equal_to_city
      add(:name => c.name, :type => 'airport', :code => c.iata, :aliases => [c.name_en, c.synonyms], :hint => c.city.name)
      add(:name => c.case_to, :type => 'airport', :code => c.iata, :hint => c.city.name)
    end
  end

end
