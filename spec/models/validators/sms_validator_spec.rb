# encoding: utf-8

require 'spec_helper'


class Validatable
  include ActiveModel::Validations
  validates :message, sms: true
  attr_accessor  :message
end


describe SMSValidator, network: true do

  subject { Validatable.new }

  context 'without message provided with' do

    specify 'nil is invalid' do
      expect(subject).to be_valid
    end

    specify 'empty string it is valid' do
      expect(subject).to be_valid
    end

  end

  # > 160
  context 'message containing 170 symbols of' do

    let(:times) { 170 }

    specify 'latin is not valid' do
      subject.message = 'f'*times
      expect(subject).to_not be_valid
    end

    specify 'cyrillic is not valid' do
      subject.message = 'f'*times
      expect(subject).to_not be_valid
    end

  end

  # < 160
  context '130 symbols' do

    let(:times) { 130 }

    specify 'latin is valid' do
      subject.message = 'f'*times
      expect(subject).to be_valid
    end

    specify 'cyrillic is invalid' do
      subject.message = 'ы'*times
      expect(subject).to_not be_valid
    end

  end

  # < 70
  context '60 symbols' do

    let(:times) { 60 }

    specify 'latin is valid' do
      subject.message = 'f'*times
      expect(subject).to be_valid
    end

    specify 'cyrillic is invalid' do
      subject.message = 'ы'*times
      expect(subject).to be_valid
    end

  end

end

