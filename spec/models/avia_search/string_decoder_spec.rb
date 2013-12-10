# encoding: utf-8
require 'spec_helper'

describe AviaSearch::StringDecoder do

  before :all do
    Timecop.freeze(Date.new(2013, 6, 1))
  end

  after :all do
    Timecop.return
  end

  def decode(string)
    # Правильнее было бы AviaSearch::StringDecoder.new.decode(...),
    # но так тест дает больше пользы
    #Timecop.freeze(Date.new(2013, 6, 1)) do
      AviaSearch.from_code(string)
    #end
  end

  context 'valid' do

    context 'one-way ticket search' do

      let(:search) { decode( 'MOW-PAR-Aug8' ) }
      subject { search }

      it { should_not be_nil }
      its(:adults) { should == 1 }
      its(:children) { should == 0 }
      its(:infants) { should == 0 }
      its(:cabin) { should == 'Y' }
      it { should have(1).segment }
    end

    context 'two-way ticket search' do

      let(:search) { decode( 'MOW-PAR-Aug8-Aug16' ) }
      subject { search }

      its(:valid?) { should be_true }
      it { should have(2).segments }

      describe 'last segment' do

        subject { search.segments.last }

        its(:from) { should == City.find_by_iata('PAR') }
        its(:to) { should == City.find_by_iata('MOW') }
        its(:date) { should == Date.parse('16th Aug 2013') }
      end

    end

    context 'implicit date' do
      it 'should be current year' do
        search = decode('MOW-PAR-Sep8')
        search.segments.last.date.should == Date.parse('8th Sep 2013')
      end

      it 'should be next year' do
        search = decode('MOW-PAR-Feb8')
        search.segments.last.date.should == Date.parse('8th Feb 2014')
      end
    end

    context 'complex route(6 segments)' do

      let(:search) { decode('MOW-PAR-Aug8;PAR-AMS-Aug16;AMS-CHC-Aug18;CHC-AMS-Aug25;AMS-PAR-Sep1;PAR-MOW-Sep5') }
      subject { search }

      its(:valid?) { should be_true }
      it { should have(6).segments }

      describe 'fifth segment' do
        subject { search.segments[4] }

        its(:from) { should == City.find_by_iata('AMS') }
        its(:to) { should == City.find_by_iata('PAR') }
        its(:date) { should == Date.parse('1st Sep 2013') }
      end

    end

    context 'shortened complex route(6 segments)' do

      let(:search) { decode('MOW-PAR-Aug8;AMS-Aug16;CHC-Aug18;AMS-Aug25;PAR-Sep1;MOW-Sep5') }
      subject { search }

      its(:valid?) { should be_true }
      it { should have(6).segments }

      describe 'fifth segment' do
        subject { search.segments[4] }

        its(:from) { should == City.find_by_iata('AMS') }
        its(:to) { should == City.find_by_iata('PAR') }
        its(:date) { should == Date.parse('1st Sep 2013') }
      end

    end

    context 'children and class' do

      let (:search) { decode 'MOW-PAR-Aug8;PAR-AMS-Aug16;2adults;infant;business' }
      subject { search }

      its(:valid?) { should be_true }
      it { should have(2).segments }

      its(:adults) { should == 2 }
      its(:children) { should == 0 }
      its(:infants) { should == 1 }
      its(:cabin) { should == 'C' }
    end

    specify('date with prefix day') { decode('MOW-AMS-6Jul').should be }
    specify('date with postfix day') { decode('MOW-AMS-Jul6').should be }
    specify('date with zero-prefixed day') { decode('MOW-AMS-06Jul').should be }
    specify('lowercase') { decode('mow-ams-jul24').should be }
    # для сирены
    specify('with cyrillic iatas') { decode('СПБ-PAR-8Aug').should be }
    specify('with cyrillic lowercase iatas') { decode('спб-PAR-8AUG').should be }
  end

  context 'invalid code with' do
    specify('incomplete segment') { decode('MOW-15Sep').should be_false }
    specify('completely wrong structure') { decode('foowalksintothebar').should be_false }
    specify('wrong month') { decode('MOW-AMS-Ju24').should be_false }
    specify('wrong adults value') { decode('MOW-AMS-Jul24-Aadults-2children-infant').should be_false }
    specify('wrong children value') { decode('MOW-AMS-Jul24-2adults-THEchildren-infant').should be_false }
    specify('wrong infants value') { decode('MOW-AMS-Jul24-3adults-2children-Yinfant').should be_false }
    # проверяется в AviaSearch.valid?
    #specify('7 segments') { decode('MOW-AMS-Jul24-PAR-Jul26-MIL-Jul31-PRG-Aug1-ROM-Aug8-MOW-Aug15-LED-Aug18').should be_false }
  end
end

