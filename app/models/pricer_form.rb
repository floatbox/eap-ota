class PricerForm < ActiveRecord::BaseWithoutTable

  class FormSegment < ActiveRecord::BaseWithoutTable
    column :from, :string
    column :to, :string
    column :date, :string
    attr_reader :to_iata, :from_iata
    validates_presence_of :from_iata, :to_iata, :date

    def to_json(args={})
      args[:methods] = (args[:methods].to_a + [:to_as_object, :from_as_object]).uniq
      super(args)
    end

    def to= name
      @to_iata =  Completer.iata_from_name(name) rescue nil
      super
    end

    def from= name
      @from_iata = Completer.iata_from_name(name) rescue nil
      super
    end

    def to_as_object
       to_iata && [City[to_iata], Airport[to_iata], Country.find_by_alpha2(to_iata)].find(&:id)
    end

    def from_as_object
      from_iata && [City[from_iata], Airport[from_iata], Country.find_by_alpha2(from_iata)].find(&:id)
    end

    def nearby_cities
      [from_as_object, to_as_object].map do |location|
        if location.class == City
          location.nearby_cities
        elsif location.class == Airport
          location.city.nearby_cities
        else
          []
        end
      end
    end
  end

  column :dates, :string
  column :rt, :string
  column :from, :string
  column :to, :string
  column :complex_to, :string
  column :adults, :integer, 1
  column :children, :integer, 0
  column :infants, :integer, 0
  column :search_type, :string, 'travel'
  column :nonstop, :boolean
  column :day_interval, :integer, 3
  column :debug, :boolean, false
  column :cabin, :string
  column :changes, :string
  has_many :form_segments

<<<<<<< HEAD
  delegate :to, :from, :from_iata, :to_iata, :to => 'form_segments.first'
=======
  validates_presence_of :from_iata, :to_iata, :date1
  validates_presence_of :date2, :if => :rt

  # FIXME заглушка пока не переделаем from и to
  attr_accessor :form_segments

>>>>>>> 95a3dcc563ae19f08c15df91806ef4a302e8454a
  attr_reader :to_iata, :from_iata, :complex_to_parse_results

  def date1
    form_segments.first.date
  end

  def date2
    form_segments[1].date if form_segments[1]
  end

  def dates
    [date1, date2] if date2
    [date1]
  end

  def save_to_cache(query_key)
    Rails.cache.write('pricer_form' + query_key, self)
  end

  def self.load_from_cache(query_key)
    Rails.cache.read('pricer_form' + query_key)
  end

  def to_json(args={})
    args[:methods] = (args[:methods].to_a + [:people_count, :complex_to_parse_results, :form_segments]).uniq
    super(args)
  end

  def rt
    (form_segments.length == 2) && (form_segments[0].to_iata == form_segments[1].from_iata) && (form_segments[1].to_iata == form_segments[0].from_iata)
  end

  def real_people_count
    #младенцы с местом считаются детьми
    {
      :adults => adults,
      :children => children + ((adults < infants) ? (infants - adults) : 0 ),
      :infants => (adults >= infants) ? infants : adults
    }
  end

  def people_count
    {:adults => adults || 1, :children => children || 0, :infants => infants || 0}
  end

  def people_count= count
    self.adults, self.children, self.infants = count[:adults] || 1, count[:children] || 0, count[:infants] || 0
  end

  def parse_complex_to
    self.complex_to ||= form_segments[0].to
    res = {}
    str = self.complex_to.mb_chars
    not_finished = true
    while !str.blank? && not_finished
      day = 0
      month_record = nil
      word_part = ''
      not_finished = false
      if m = str.match(/(\S+)\s+(\d)+\s*$/)
        word_part = m[0].mb_chars
        month_record = Completer.record_from_string(m[1].mb_chars, ['date'])
        day = m[2].to_i
      elsif m = str.match(/(\d+)\s+(\S+)\s*$/)
        word_part = m[0].mb_chars
        month_record = Completer.record_from_string(m[2].mb_chars, ['date'])
        day = m[1].to_i
      end

      if month_record && (day > 0) && (month_record.hidden_info.class == Fixnum)
        res[:dates] =[{
            :value => date_from_month_and_day(month_record.hidden_info, day),
            :str => word_part.to_s,
            :start => str.length - word_part.length,
            :end => str.length-1}
          ]
        str = str[0...(str.length - word_part.length)]
        not_finished = true
      end
      
      for word_beginning_pattern in [ /\S+\s+\S+\s+\S+\s*$/, /\S+\s+\S+\s*$/, /\S+\s*$/ ]
        if (m = str.match(word_beginning_pattern)) && !not_finished
          word_part = m[0].mb_chars

          if r = Completer.record_from_string(word_part, ['date', 'airport', 'city', 'country', 'people'])
            if r && r.type == 'date' && r.hidden_info.class == String
              res[:dates] = [{
                  :value => r.hidden_info,
                  :str => word_part.to_s,
                  :start => str.length - word_part.length,
                  :end => str.length-1}
                ]
              str = str[0...(str.length - word_part.length)]
              not_finished = true
            elsif r && (['airport', 'city', 'country'].include? r.type)
              @to_iata = r.code rescue nil
              res[:to] = {
                :value => @to_iata,
                :str => word_part.to_s,
                :start => str.length - word_part.length,
                :end => str.length-1
              }
              str = str[0...(str.length - word_part.length)]
              not_finished = true
            elsif r && r.type == 'people'
              res[:people_count] = {
                :value => r.hidden_info,
                :str => word_part.to_s,
                :start => str.length - word_part.length,
                :end => str.length-1
              }
              str = str[0...(str.length - word_part.length)]
              not_finished = true
            end
          end
        end
      end
    end
    @complex_to_parse_results = res
  end
  
  def date_from_month_and_day(month, day)
    self.date1 = (Date.today > Date.new(Date.today.year, month, day)) ?
      Date.new(Date.today.year+1, month, day).strftime('%d%m%y') : 
      Date.new(Date.today.year, month, day).strftime('%d%m%y')
  end 

  def to_key
    []
  end

  def human
    return "запрос не полон" unless valid?
    r = []

    locations = human_locations
    if locations[:dpt_0] && locations[:arv_0]
      r << "<span class=\"locations\">#{locations[:dpt_0]} #{locations[:arv_0]}</span>"
    end

    if adults > 1
      r << ['вдвоем', 'втроем', 'вчетвером', 'впятером', 'вшестером', 'всемером', 'ввосьмером'][adults-2]
    end
    if children > 0
      r << ['с&nbsp;ребенком', 'с&nbsp;двумя детьми', 'с&nbsp;тремя детьми', 'с&nbsp;четыремя детьми', 'с&nbsp;пятью детьми', 'с&nbsp;шестью детьми', 'с&nbsp;семью детьми'][children-1]
    end
    r << 'и' if infants > 0 && children > 0
    if infants > 0
      r << ['с&nbsp;младенцем', 'с&nbsp;двумя младенцами', 'с&nbsp;тремя младенцами', 'с&nbsp;четыремя младенцами', 'с&nbsp;пятью младенцами', 'с&nbsp;шестью младенцами', '7 младенцев'][infants-1]
    end

    r << human_cabin if cabin

    r << "<span class=\"date\" data-date=\"#{[date1[0,2],date1[2,2]].join('.')}\">#{human_date(date1)}</span>"

    if rt
      r << 'и&nbsp;обратно'
      r << "<span class=\"date\" data-date=\"#{[date2[0,2],date1[2,2]].join('.')}\">#{human_date(date2)}</span>"
    end

    r.join(' ')
  end

  def human_cabin
    case cabin
    when 'Y'
      return 'эконом-классом'
    when 'C'
      return 'бизнес-классом'
    when 'F'
      return 'первым классом'
    end
  end

  def nearby_cities
    #FIXME
    form_segments[0].nearby_cities
  end

  def human_locations
    #FIXME
    fl = form_segments[0].from_as_object
    tl = form_segments[0].to_as_object
    result = {
      :dpt_0 => fl && fl.case_from,
      :arv_0 => tl && tl.case_to,
    }
    if rt
      result[:dpt_1] = tl && tl.case_from
      result[:arv_1] = fl && fl.case_to
    end
    result
  end

  def human_date(ds)
    d = Date.strptime(ds, '%d%m%y')
    if d.year == Date.today.year
      return I18n.l(d, :format => '%e&nbsp;%B')
    else
      return I18n.l(d, :format => '%e&nbsp;%B %Y')
    end
  end

  def search
    case search_type
    when 'travel'
      Amadeus::Service.fare_master_pricer_travel_board_search(self)
    when 'calendar'
      Amadeus::Service.fare_master_pricer_calendar(self)
    end.recommendations
    # .select(&:sellable?)
  end

end

