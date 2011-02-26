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
  column :bonuscard_number, :string, 'Номер карты'
  column :number_in_amadeus, :integer
  column :ticket, :string
  validates_presence_of :first_name, :last_name, :sex, :nationality_id, :birthday, :passport
  validates_presence_of :document_expiration_date, :unless => :document_noexpiration
  # FIXME WRONG! фамилии через дефис? два имени? сокращения?
  validates_format_of :first_name, :with => /^[a-zA-Z]*$/, :message => "Некорректное имя"
  validates_format_of :last_name,  :with => /^[a-zA-Z]*$/, :message => "Некорректная фамилия"
  validate :check_age
  attr_accessor :flight_date, :infant_or_child

  def smart_document_expiration_date
    document_noexpiration ? (Date.today + 18.months) : document_expiration_date
  end

  def coded
    res = "#{first_name}/#{last_name}/#{sex}/#{nationality.alpha3}/#{birthday.strftime('%d%b%y').upcase}/#{passport}/"
    res += "expires:#{document_expiration_date.strftime('%d%b%y').upcase}/" unless document_noexpiration
    res += "bonus: #{bonuscard_type}#{bonuscard_number}/" if bonus_present
    res += "child" if infant_or_child == 'c'
    res += "infant" if infant_or_child == 'i'
    res
  end

  def first_name_with_code
    if infant_or_child
      first_name
    else
      first_name + ' ' + (sex == 'f' ? 'MRS' : 'MR')
    end
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
