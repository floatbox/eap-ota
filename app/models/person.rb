class Person < ActiveRecord::BaseWithoutTable
  column :first_name, :string, "Имя"
  column :last_name, :string, "Фамилия"
  column :sex, :string
  column :nationality_id, :integer
  column :birthday, :date
  column :document_expiration_date, :date
  column :passport, :string, "Номер документа"
  column :document_noexpiration, :boolean, false
  column :bonus_present, :boolean, false
  column :bonuscard_type, :string
  column :bonuscard_number, :string, 'Номер карты'
  validates_presence_of :first_name, :last_name, :sex, :nationality_id, :birthday, :passport
  validates_presence_of :document_expiration_date, :unless => :document_noexpiration
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

  def validate
    errors.add :first_name,       "Некорректное имя"    if first_name && !(first_name =~ /^[a-zA-Z]*$/)
    errors.add :last_name,       "Некорректная фамилия"    if first_name && !(last_name =~ /^[a-zA-Z]*$/)
    check_infant_or_child_age(infant_or_child == 'i') if infant_or_child && flight_date
  end

  def nationality
    Country.find_by_id(nationality_id) if nationality_id
  end

  def check_infant_or_child_age(infant=true)
    if birthday && (birthday + (infant ? 2 : 13).years <= flight_date)
      errors.add :birthday, "на момент вылета будет более #{infant ? '1 года' : '12 лет'}"
    end
  end

end
