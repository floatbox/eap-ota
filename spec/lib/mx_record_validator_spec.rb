require 'spec_helper'
require 'active_model'
#require 'lib/mx_record_validator'


class Validatable
  include ActiveModel::Validations
  validates :email, mx_record: true
  attr_accessor  :email
end


describe MxRecordValidator, network: true do

  subject { Validatable.new }

  context 'without email' do
    it 'is valid and works with nil' do
      expect(subject).to be_valid
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

