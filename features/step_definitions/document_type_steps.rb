Пусть /^введены данные человека$/ do
  @person = Person.new
end

Пусть /^у человека дата рождения "([^"]*)"$/ do |date|
  @person.birthday = Date.strptime(date, '%d.%m.%y')
end

Пусть /^гражданство "([^"]*)"$/ do |nationality|
  @person.nationality_id = Country.find_by_alpha2(nationality).id
end

Пусть /^срок действия документа "([^"]*)"$/ do |document_expires|
  @person.document_noexpiration = (document_expires.mb_chars != 'есть'.mb_chars)
end

Если /^пользователь ввел номер документа "([^"]*)"$/ do |number|
  @person.passport = number
end

То /^в сирену в качестве типа документа будет передан "([^"]*)"$/ do |doccode_sirena|
  @person.doccode_sirena.to_s.mb_chars.should == doccode_sirena.mb_chars
end

То /^в сирены в качестве номера документа будет передан "([^"]*)"$/ do |number_sirena|
  @person.passport_sirena.to_s.mb_chars.should == number_sirena.mb_chars
end

То /^в амадеус в качестве номера документа будет передан "([^"]*)"$/ do |number_amadeus|
  @person.cleared_passport.mb_chars.should == number_amadeus.mb_chars
end

