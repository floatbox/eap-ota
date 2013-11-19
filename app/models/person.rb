# encoding: utf-8

class Person

  include Virtus.model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  attribute :first_name,            String
  attribute :last_name,             String
  attribute :sex,                   String
  attribute :nationality_code,      String
  attribute :birthday,              Date
  attribute :document_expiration,   Date
  attribute :passport,              String
  attribute :document_noexpiration, Boolean, default: false
  attribute :bonus_present,         Boolean, default: false
  attribute :bonuscard_type,        String
  attribute :bonuscard_number,      String
  attribute :number_in_amadeus,     Integer
  attribute :with_seat,             Boolean, default: false

  # можно тоже превратить в аттрибуты virtus при желании
  attr_accessor :passenger_ref, :tickets, :associated_infant
  attr_accessor :infant, :child

  validates_presence_of :sex, :nationality_code, :birthday
  # FIXME WRONG! фамилии через дефис? два имени? сокращения?
  validates :first_name,
    presence: true,
    format: { with: /^[a-zA-Z-]*$/, message: "Некорректное имя" }
  validates :last_name,
    presence: true,
    format: { with: /^[a-zA-Z-]*$/, message: "Некорректная фамилия" }
  validates :passport, presence: true, with: :check_passport
  validates :document_expiration, presence: true, unless: :document_noexpiration

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

  def smart_document_expiration_date
    document_noexpiration ? (Date.today + 18.months) : document_expiration
  end

  def coded
    res = "#{first_name}/#{last_name}/#{sex}/#{nationality.alpha3}/#{birthday.strftime('%d%b%y').upcase}/#{passport}/"
    res += "expires:#{document_expiration.strftime('%d%b%y').upcase}/" unless document_noexpiration
    res += "bonus: #{bonuscard_type}#{bonuscard_number}/" if bonus_present
    res += "child" if child
    res += "infant" if infant
    res
  end

  def cleared_passport
    Russian.translit(passport.mb_chars.gsub(/[^a-zA-Z\dа-яА-Я]+/, ''))
  end

  def doccode_sirena
    if nationality == "RUS"
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
    errors.add :passport, 'Неверный номер документа' unless doccode_sirena
  end

  def nationality
    # [].first => nil, так что find_by* - совместимо
    Country.where(alpha3: nationality_code).first
  end
end

