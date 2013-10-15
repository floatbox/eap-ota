# encoding: utf-8
require 'spec_helper'

describe Person do
  let(:adult_attributes) do
    {"document_noexpiration"=>"0",
     "birthday_year"=>"1984",
     "birthday_month"=>"06",
     "birthday_day"=>"16",
     "nationality_code"=>"RUS",
     #"bonuscard_type"=>"[FILTERED]",
     #"bonuscard_number"=>"[FILTERED]",
     "document_expiration_year"=>"2014",
     "document_expiration_month"=>"09",
     "document_expiration_day"=>"08",
     "sex"=>"m",
     "last_name"=>"IVASHKIN",
     "bonus_present"=>"0",
     "passport"=>"123456789",
     "first_name"=>"ALEKSEY"}
  end

  subject { Person.new(adult_attributes).tap(&:valid?) }

  its(:birthday) {should == Date.new(1984, 6, 16)}
  its(:document_expiration) {should == Date.new(2014, 9, 8)}

  describe '#too_long_names?' do
    subject do
      build(:person, :associated_infant => associated_infant, :first_name => ('A'*10), :last_name => last_name, :sex => sex, :child => child)
    end
    let(:child) {nil}

    context 'adult with infant' do
      let(:associated_infant) do
        build :person, :infant, :first_name => infant_first_name, :last_name => infant_last_name
      end
      let(:last_name) {'A' * 10}

      context 'with same last name' do
        let(:infant_last_name){'A'*10}

        context 'male' do
          # ограничение амадеуса - имя + имя младенца + фамилия <= 52 символов
          let(:sex) {'m'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 33}
            its(:too_long_names?){should be_true}
          end

          context "with short names" do
            let(:infant_first_name) {'I' * 32}
            its(:too_long_names?){should be_false}
          end
        end

        context 'female' do
          # ограничение амадеуса - имя + имя младенца + фамилия <= 51 символов
          let(:sex) {'f'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 32}
            its(:too_long_names?){should be_true}
          end

          context "with short names" do
            let(:infant_first_name) {'I' * 31}
            its(:too_long_names?){should be_false}
          end
        end
      end

      context 'with different last name' do
        let(:infant_last_name){'I'*10}
        context 'male' do
          # ограничение амадеуса - имя + имя младенца + фамилия + фамилия младенца <= 52 символов
          let(:sex) {'m'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 23}
            its(:too_long_names?){should be_true}
          end


          context "with short names" do
            let(:infant_first_name) {'I' * 22}
            its(:too_long_names?){should be_false}
          end
        end

        context 'female' do
          # ограничение амадеуса - имя + имя младенца + фамилия + фамилия младенца <= 51 символов
          let(:sex) {'f'}
          context "with too long names" do
            let(:infant_first_name) {'I' * 22}
            its(:too_long_names?){should be_true}
          end


          context "with short names" do
            let(:infant_first_name) {'I' * 21}
            its(:too_long_names?){should be_false}
          end
        end
      end
    end

    context 'without infant' do
      let(:associated_infant) {nil}

      context 'male' do
        #ограничение - 66 символов
        let(:sex) {'m'}
        context 'with long name' do
          let(:last_name) {'A' * 57}
          its(:too_long_names?){should be_true}
        end

        context 'with short name' do
          let(:last_name) {'A' * 56}
          its(:too_long_names?){should be_false}
        end
      end

      context 'female' do
        #ограничение - 65 символа
        let(:sex) {'f'}
        context 'with long name' do
          let(:last_name) {'A' * 56}
          its(:too_long_names?){should be_true}
        end

        context 'with short name' do
          let(:last_name) {'A' * 55}
          its(:too_long_names?){should be_false}
        end
      end

      context 'male child' do
        let(:sex) {'m'}
        let(:child) {true}

        context 'with long name' do
          let(:last_name) {'A' * 47}
          its(:too_long_names?){should be_true}
        end

        context 'with short name' do
          let(:last_name) {'A' * 46}
          its(:too_long_names?){should be_false}
        end
      end

      context 'female child' do
        let(:sex) {'f'}
        let(:child) {true}

        context 'with long name' do
          let(:last_name) {'A' * 47}
          its(:too_long_names?){should be_true}
        end

        context 'with short name' do
          let(:last_name) {'A' * 46}
          its(:too_long_names?){should be_false}
        end
      end


    end

  end
end
