# encoding: utf-8
class Person
  include Mongoid::Document
  field :first_name, :type => String
  field :last_name, :type => String
  field :sex, :type => String
  # FIXME убрать где-нибудь в ноябре
  field :nationality_id, :type => Integer
  field :nationality_code, :type => String
  field :birthday, :type => Date
  field :document_expiration_date, :type => Date
  field :passport, :type => String
  field :document_noexpiration, :type => Boolean, :default => false
  field :bonus_present, :type => Boolean, :default => false
  field :bonuscard_type, :type => String
  field :bonuscard_number, :type => String
  field :number_in_amadeus, :type => Integer
  field :with_seat, :type => Boolean, :default => false

  attr_accessor :passenger_ref, :tickets, :associated_infant

  validates_presence_of :first_name, :last_name, :sex, :nationality, :birthday, :passport
  validates_presence_of :document_expiration_date, :unless => :document_noexpiration
  # FIXME WRONG! фамилии через дефис? два имени? сокращения?
  validates_format_of :first_name, :with => /^[a-zA-Z-]*$/, :message => "Некорректное имя"
  validates_format_of :last_name,  :with => /^[a-zA-Z-]*$/, :message => "Некорректная фамилия"
  validate :check_passport
  attr_accessor :infant, :child

  # совместимость с "активрекордным" стилем
  before_validation :set_birthday
  before_validation :set_document_expiration_date
  before_validation :clear_first_name_and_last_name


  def too_long_names?
    if associated_infant
      name_str = first_name_with_code + last_name + associated_infant.first_name
      name_str += associated_infant.last_name if associated_infant.last_name != last_name
      name_str.length > 55
    elsif child
      (first_name_with_code + last_name).length > 56
    elsif !infant
      (first_name_with_code + last_name).length > 69
    end
  end

  # ребенок до 2-х лет без явно указанного места
  def potential_infant?(last_flight_date)
    (birthday + 2.years > last_flight_date) && !with_seat
  end

  def adult?(last_flight_date=nil)
    if last_flight_date && birthday
      birthday + 12.years <= last_flight_date
    else
      !child && !infant
    end
  end

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

  def coded
    res = "#{first_name}/#{last_name}/#{sex}/#{nationality.alpha3}/#{birthday.strftime('%d%b%y').upcase}/#{passport}/"
    res += "expires:#{document_expiration_date.strftime('%d%b%y').upcase}/" unless document_noexpiration
    res += "bonus: #{bonuscard_type}#{bonuscard_number}/" if bonus_present
    res += "child" if child
    res += "infant" if infant
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
      return "СР" if passport.mb_chars.gsub(/[^a-zA-Z\dа-яА-Я]+/, '').match(/^[\dA-Za-z]{1,5}[а-яА-Яa-zA-Z]{2}\d{6}$/) && (Date.today - 14.years <= birthday)
      return "ПС" if passport.mb_chars.gsub(/[^\d]+/, '').match(/^\d{10}$/) && (Date.today - 14.years >= birthday)
      return "ПСП" if passport.mb_chars.gsub(/[^\d]+/, '').match(/^\d{9}$/) && !document_noexpiration
      return nil
    elsif cleared_passport.mb_chars.length > 5
      return document_noexpiration ? "НП" : "ЗА"
    end
  end

  def first_name_with_code
    if adult?
      first_name + ' ' + (sex == 'f' ? 'MRS' : 'MR')
    else
      first_name
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
    if nationality_id
      Country.find_by_id(nationality_id)
    elsif nationality_code
      Country.find_by_alpha3(nationality_code)
    end
  end
end

