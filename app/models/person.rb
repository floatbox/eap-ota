class Person < ActiveRecord::BaseWithoutTable
  column :first_name, :string, "Имя"
  column :last_name, :string, "Фамилия"
  column :sex, :string
  column :nationality_id, :integer
  column :birthday, :date
  column :document_expiration_date, :date
  column :passport, :string, "Номер документа"
  column :document_noexpiration, :boolean
  column :bonus_present, :boolean, false
  column :bonuscard_type, :string
  column :bonuscard_number, :string, 'Номер карты'
  validates_multiparameter_assignments
  validates_presence_of :first_name, :last_name, :sex, :nationality_id, :birthday, :passport
  validates_presence_of :document_expiration_date, :unless => :document_noexpiration
  attr_accessor :flight_date, :infant_or_child

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
