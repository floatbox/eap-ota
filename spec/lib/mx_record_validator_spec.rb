require 'spec_helper'
require 'active_model'
#require 'lib/mx_record_validator'


describe MxRecordValidator, network: true do

  class Validatable
    include ActiveModel::Validations
    validates :email, mx_record: true
    attr_accessor  :email
  end

  subject { Validatable.new }

  context 'without email' do
    it 'is valid and works with nil' do
      expect(subject).to be_valid
    end
  end

  context 'with blank email' do
    it 'is not valid' do
      subject.email = ''
      expect(subject).to_not be_valid
    end
  end


  context 'with mx-containing domain' do
    it 'is not valid' do
      subject.email = 'pony@yandex.ru'
      expect(subject).to be_valid
    end
  end

  context 'without mx-containing domain' do
    it 'is valid' do
      subject.email = 'phony@ynex.ru'
      expect(subject).to_not be_valid
    end
  end

end

