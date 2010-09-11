class Person < ActiveRecord::BaseWithoutTable
  column :first_name, :string, "Имя"
  column :last_name, :string, "Фамилия"
  column :sex, :string
  column :nationality_id, :integer
  belongs_to :nationality, :class_name => 'Country'
  column :birthday, :date
  column :document_expiration_date, :date
  column :passport, :string, "Номер документа"
  column :document_noexpiration, :boolean
  column :bonus_present, :boolean
  column :bonuscard_type, :string
  column :bonuscard_number, :string, 'Номер карты'
  
  
end
