class PricerForm < ActiveRecord::BaseWithoutTable

  column :from, :string
  column :to, :string
  column :complex_to, :string
  column :date1, :string
  column :date2, :string
  column :rt, :boolean
  column :adults, :integer, 1
  column :children, :integer, 0
  column :infants, :integer, 0
  column :search_type, :string, 'travel'
  column :nonstop, :boolean
  column :day_interval, :integer, 3
  column :debug, :boolean, false
  column :cabin, :string
  column :changes, :string

  validates_presence_of :from_iata, :to_iata, :date1
  validates_presence_of :date2, :if => :rt

  attr_reader :to_iata, :from_iata, :complex_to_parse_results

  def to_json(args={})
    args[:methods] = (args[:methods].to_a + [:dates, :people_count, :complex_to_parse_results, :to_as_object, :from_as_object]).uniq
    super(args)
  end

  def real_people_count
    #младенцы с местом считаются детьми
    {
      :adults => adults,
      :children => children + ((adults < infants) ? (infants - adults) : 0 ),
      :infants => (adults >= infants) ? infants : adults
    }
  end


  #временная херня
  def dates
    return [date1, date2] if date1 && date2
    return [date1] if date1
  end

  def dates= dates
    self.date1 = dates[0] if dates.length > 0
    self.date2 = dates[1] if dates.length > 1
  end

  def people_count
    {:adults => adults || 1, :children => children || 0, :infants => infants || 0}
  end

  def people_count= count
    self.adults, self.children, self.infants = count[:adults] || 1, count[:children] || 0, count[:infants] || 0
  end

  def parse_complex_to
    self.complex_to ||= to
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

  def to= name
    @to_iata =  Completer.iata_from_name(name) rescue nil
    super
  end

  def from= name
    @from_iata = Completer.iata_from_name(name) rescue nil
    super
  end


  def to_key
    []
  end

  def human
    return "запрос не полон" unless valid?
    r = []

    locations = human_locations
    if locations[:dpt_0]
      r << locations[:dpt_0] 
    end
    if locations[:arv_0]
      r << locations[:arv_0]
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

    r << human_dates(Date.strptime(date1, '%d%m%y'))

    if rt
      r << 'и&nbsp;обратно'
      r << human_dates(Date.strptime(date2, '%d%m%y'))
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

  def to_as_object
    to_iata && [City[to_iata], Airport[to_iata], Country.find_by_alpha2(to_iata)].find(&:id)
  end

  def from_as_object
    from_iata && [City[from_iata], Airport[from_iata], Country.find_by_alpha2(from_iata)].find(&:id)
  end

  def human_locations
    fl = from_as_object
    tl = to_as_object
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

  def human_dates(d1, d2=nil)
    if d2.blank?
      if d1.year == Date.today.year
        return I18n.l(d1, :format => '%e&nbsp;%B')
      else
        return I18n.l(d1, :format => '%e&nbsp;%B %Y')
      end

    else
      if d1.year == d2.year
        if d1.month == d2.month
          f1, f2 = '%e', '%e %B'
        else
          f1, f2 = '%e %B', '%e %B'
        end

        if d1.year != Date.today.year
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

