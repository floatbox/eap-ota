# encoding: utf-8
require 'spec_helper'

describe 'проверяем, правильно ли угадывается тип документа' do
  def convert(passport, nationality_code, birthday, document_noexpiration)
    p = Person.new(
      :passport => passport,
      :birthday => birthday,
      :document_noexpiration => document_noexpiration
    )
    p.stub!(:nationality).and_return(Country.new(:alpha2 => nationality_code))
    p.doccode_sirena
  end

  specify {convert(' VI ИК-018648', "RU", 10.years.ago.to_date, true).should == 'СР'}
  specify {convert('5ИК-018648', "RU", 10.years.ago.to_date, true).should == 'СР'}
  specify {convert('4565 № 018648', "RU", 20.years.ago.to_date, true).should == 'ПС'}
  specify {convert('34 N4587421', "RU", 20.years.ago.to_date, false).should == 'ПСП'}
  specify {convert('456#5018648', "GB", 20.years.ago.to_date, true).should == 'НП'}
  specify {convert('456#Ы5018648', "GB", 20.years.ago.to_date, false).should == 'ЗА'}
  specify {convert('456#Ы506489', "RU", 20.years.ago.to_date, true).should == nil}
  specify {convert('IIIАК532098', "RU", 1.year.ago.to_date, true).should == 'СР'}
  specify {convert('3АК532098', "RU", 1.year.ago.to_date, true).should == 'СР'}

end

