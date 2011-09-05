# encoding: utf-8
class Person
  include Mongoid::Document
  field :first_name, :type => String
  field :last_name, :type => String
  field :sex, :type => String
  field :nationality_id, :type => Integer
  field :birthday, :type => Date
  field :document_expiration_date, :type => Date
  field :passport, :type => String
  field :document_noexpiration, :type => Boolean, :default => false
  field :bonus_present, :type => Boolean, :default => false
  field :bonuscard_type, :type => String
  field :bonuscard_number, :type => String
  field :number_in_amadeus, :type => Integer
  field :ticket, :type => String

  attr_accessor :passenger_ref, :ticket_hash

  validates_presence_of :first_name, :last_name, :sex, :nationality_id, :birthday, :passport
  validates_presence_of :document_expiration_date, :unless => :document_noexpiration
  # FIXME WRONG! фамилии через дефис? два имени? сокращения?
  validates_format_of :first_name, :with => /^[a-zA-Z-]*$/, :message => "Некорректное имя"
  validates_format_of :last_name,  :with => /^[a-zA-Z-]*$/, :message => "Некорректная фамилия"
  validate :check_age, :check_passport
  attr_accessor :flight_date, :infant_or_child

  # совместимость с "активрекордным" стилем
  before_validation :set_birthday
  before_validation :set_document_expiration_date
  before_validation :clear_first_name_and_last_name

  def clear_first_name_and_last_name
    first_name.gsub!(/[^\w]+/, '')
    last_name.gsub!(/[^\w]+/, '')
  end

  def set_birthday
    self.birthday ||=
      (1..3).collect { |n| attributes["birthday(#{n}i)"] }.join('-')
  end

  def set_document_expiration_date
    unless document_noexpiration
      self.document_expiration_date ||=
        (1..3).collect { |n| attributes["document_expiration_date(#{n}i)"] }.join('-')
    end
  end

  def smart_document_expiration_date
    document_noexpiration ? (Date.today + 18.months) : document_expiration_date
  end

  def ticket_number
    (ticket.match(/([\d\w]+)-{0,1}(\d{10}-{0,1}\d*)/).to_a)[2]
  end

  def ticket_code
    (ticket.match(/([\d\w]+)-{0,1}(\d{10}-{0,1}\d*)/).to_a)[1]
  end

  def coded
    res = "#{first_name}/#{last_name}/#{sex}/#{nationality.alpha3}/#{birthday.strftime('%d%b%y').upcase}/#{passport}/"
    res += "expires:#{document_expiration_date.strftime('%d%b%y').upcase}/" unless document_noexpiration
    res += "bonus: #{bonuscard_type}#{bonuscard_number}/" if bonus_present
    res += "child" if infant_or_child == 'c'
    res += "infant" if infant_or_child == 'i'
    res
  end

  def cleared_passport
    Russian.translit(passport.mb_chars.gsub(/[^a-zA-Z\dа-яА-Я]+/, ''))
  end

  def passport_sirena
    if doccode_sirena == "СР"
      passport.mb_chars.gsub(/[^a-zA-Z\dа-яА-Я]+/, '')
    elsif ["ПС", "ПСП"].include? doccode_sirena
      passport.mb_chars.gsub(/[^\d]+/, '')
    elsif doccode_sirena.present?
      passport.mb_chars.gsub(/[^a-zA-Z\dа-яА-Я]+/, '')
    end
  end

  def doccode_sirena
    if nationality && nationality.alpha2 == "RU"
      return "СР" if passport.mb_chars.gsub(/[^a-zA-Z\dа-яА-Я]+/, '').match(/^[\dA-Za-z]{1,2}[а-яА-Яa-zA-Z]{2}\d{6}$/) && (Date.today - 14.years <= birthday)
      return "ПС" if passport.mb_chars.gsub(/[^\d]+/, '').match(/^\d{10}$/) && (Date.today - 14.years >= birthday)
      return "ПСП" if passport.mb_chars.gsub(/[^\d]+/, '').match(/^\d{9}$/) && !document_noexpiration
      return nil
    elsif cleared_passport.mb_chars.length > 5
      return document_noexpiration ? "НП" : "ЗА"
    end
  end

  def first_name_with_code
    if infant_or_child
      first_name
    else
      first_name + ' ' + (sex == 'f' ? 'MRS' : 'MR')
    end
  end

  def check_passport
    #errors.add :first_name, "Некорректное имя" if first_name_sirena.length < 3
    errors.add :passport, 'Неверный номер документа' unless doccode_sirena
  end

  def first_name_sirena
    corrected_name = first_name.mb_chars.upcase.gsub('Ё', 'Е').gsub('Ъ', 'Ь').gsub(/[^a-zA-Zа-яА-Я]+/, '')
    #corrected_name += '.' if corrected_name.length < 3
    corrected_name
  end

  def nationality
    Country.find_by_id(nationality_id) if nationality_id
  end

  def check_age
    check_infant_or_child_age(infant_or_child == 'i') if infant_or_child && flight_date
  end

  # FIXME а если день рождения между рейсами?
  def check_infant_or_child_age(infant=true)
    if birthday && (birthday + (infant ? 2 : 12).years <= flight_date)
      errors.add :birthday, "на момент вылета будет более #{infant ? '2 лет' : '12 лет'}"
    end
  end

end

