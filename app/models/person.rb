# encoding: utf-8
class Person < ActiveRecord::BaseWithoutTable
  column :first_name, :string
  column :last_name, :string
  column :sex, :string
  column :nationality_id, :integer
  column :birthday, :date
  column :document_expiration_date, :date
  column :passport, :string
  column :document_noexpiration, :boolean, false
  column :bonus_present, :boolean, false
  column :bonuscard_type, :string
  column :bonuscard_number, :string
  column :number_in_amadeus, :integer
  column :ticket, :string
  column :passenger_ref, :integer
  validates_presence_of :first_name, :last_name, :sex, :nationality_id, :birthday, :passport
  validates_presence_of :document_expiration_date, :unless => :document_noexpiration
  # FIXME WRONG! фамилии через дефис? два имени? сокращения?
  validates_format_of :first_name, :with => /^[a-zA-Z-]*$/, :message => "Некорректное имя"
  validates_format_of :last_name,  :with => /^[a-zA-Z-]*$/, :message => "Некорректная фамилия"
  validate :check_age, :check_passport
  attr_accessor :flight_date, :infant_or_child

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
      return "СР" if passport.mb_chars.gsub(/[^a-zA-Z\dа-яА-Я]+/, '').match(/[\dA-Za-z]{1,2}[а-яА-Яa-zA-Z]{2}\d{6}/) && (Date.today - 14.years <= birthday)
      return "ПС" if passport.mb_chars.gsub(/[^\d]+/, '').match(/\d{10}/) && (Date.today - 14.years >= birthday)
      return "ПСП" if passport.mb_chars.gsub(/[^\d]+/, '').match(/\d{9}/) && !document_noexpiration
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

