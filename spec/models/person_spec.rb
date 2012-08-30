# encoding: utf-8
require 'spec_helper'

describe Person do
  let(:adult_attributes) do
    {"document_noexpiration"=>"0",
     "birthday(1i)"=>"1984",
     "birthday(2i)"=>"06",
     "birthday(3i)"=>"16",
     "nationality_id"=>"170",
     #"bonuscard_type"=>"[FILTERED]",
     #"bonuscard_number"=>"[FILTERED]",
     "document_expiration_date(1i)"=>"2014",
     "document_expiration_date(2i)"=>"09",
     "document_expiration_date(3i)"=>"08",
     "sex"=>"m",
     "last_name"=>"IVASHKIN",
     "bonus_present"=>"0",
     "passport"=>"123456789",
     "first_name"=>"ALEKSEY"}
  end

  subject { Person.new(adult_attributes).tap(&:valid?) }

  its(:birthday) {should == Date.new(1984, 6, 16)}
  its(:document_expiration_date) {should == Date.new(2014, 9, 8)}

  describe '#correct_long_name' do
    subject do
      p = build(:person, :associated_infant => associated_infant, :first_name => ('A'*10), :last_name => last_name, :sex => sex, :infant_or_child => infant_or_child)
      p.correct_long_name
      p
    end

    context 'adult with infant' do
      let(:associated_infant) do
        build :person, :infant, :first_name => infant_first_name, :last_name => infant_last_name
      end
      let(:infant_or_child) {nil}
      let(:last_name) {'A' * 10}

      context 'with same last name' do
        let(:infant_last_name){'A'*10}

        context 'male' do
          # ограничение амадеуса - имя + имя младенца + фамилия <= 36 символов
          let(:sex) {'m'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 17}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I' * 17}
          end

          context "with extremely long names" do
            let(:infant_first_name) {'I' * 30}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I'}
          end

          context "with short names" do
            let(:infant_first_name) {'I' * 16}
            its(:first_name) {should == 'A' * 10}
            its('associated_infant.first_name') {should == 'I' * 16}
          end
        end

        context 'female' do
          # ограничение амадеуса - имя + имя младенца + фамилия <= 35 символов
          let(:sex) {'f'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 16}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I' * 16}
          end

          context "with extremely long names" do
            let(:infant_first_name) {'I' * 30}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I'}
          end

          context "with short names" do
            let(:infant_first_name) {'I' * 15}
            its(:first_name) {should == 'A' * 10}
            its('associated_infant.first_name') {should == 'I' * 15}
          end
        end
      end

      context 'with different last name' do
        let(:infant_last_name){'I'*10}
        context 'male' do
          # ограничение амадеуса - имя + имя младенца + фамилия + фамилия младенца <= 36 символов
          let(:sex) {'m'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 7}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I' * 7}
          end

          context "with extremely long names" do
            let(:infant_first_name) {'I' * 20}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I'}
          end

          context "with short names" do
            let(:infant_first_name) {'I' * 6}
            its(:first_name) {should == 'A' * 10}
            its('associated_infant.first_name') {should == 'I' * 6}
          end
        end

        context 'female' do
          # ограничение амадеуса - имя + имя младенца + фамилия + фамилия младенца <= 35 символов
          let(:sex) {'f'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 6}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I' * 6}
          end

          context "with extremely long names" do
            let(:infant_first_name) {'I' * 20}
            its(:first_name) {should == 'A'}
            its('associated_infant.first_name') {should == 'I'}
          end

          context "with short names" do
            let(:infant_first_name) {'I' * 5}
            its(:first_name) {should == 'A' * 10}
            its('associated_infant.first_name') {should == 'I' * 5}
          end
        end
      end
    end

    context 'without infant' do
      let(:associated_infant) {nil}

      context 'male' do
        #ограничение - 55 символов
        let(:sex) {'m'}
        let(:infant_or_child) {nil}
        context 'with long name' do
          let(:last_name) {'A' * 46}
          its(:first_name) {should == 'A'}
        end

        context 'with short name' do
          let(:last_name) {'A' * 45}
          its(:first_name) {should == 'A' * 10}
        end
      end

      context 'female' do
        #ограничение - 54 символа
        let(:sex) {'f'}
        let(:infant_or_child) {nil}
        context 'with long name' do
          let(:last_name) {'A' * 45}
          its(:first_name) {should == 'A'}
        end

        context 'with short name' do
          let(:last_name) {'A' * 44}
          its(:first_name) {should == 'A' * 10}
        end
      end

      context 'male child' do
        let(:sex) {'m'}
        let(:infant_or_child) {'c'}

        context 'with long name' do
          let(:last_name) {'A' * 49}
          its(:first_name) {should == 'A'}
        end

        context 'with short name' do
          let(:last_name) {'A' * 48}
          its(:first_name) {should == 'A' * 10}
        end
      end

      context 'female child' do
        let(:sex) {'f'}
        let(:infant_or_child) {'c'}

        context 'with long name' do
          let(:last_name) {'A' * 49}
          its(:first_name) {should == 'A'}
        end

        context 'with short name' do
          let(:last_name) {'A' * 48}
          its(:first_name) {should == 'A' * 10}
        end
      end


    end

  end
end
