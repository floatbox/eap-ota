# encoding: utf-8
require 'spec_helper'

describe Urls::Search::Encoder do

  let(:filler) { Urls::Search::FILLER_CHARACTER }

  def get_url(params={})
    adults = params[:adults] || 1
    children = params[:children] || 1
    infants = params[:infants] || 0
    cabin = params[:cabin] || 'B'
    segments = params[:segments] || []

    segments_hash = {}

    segments.each_with_index do |segment, index|
      from, to, date = segment
      segments_hash[index.to_s] = {
        from: from,
        to: to,
        date: Date.parse(date)
      }
    end

    pricer_form = PricerForm.new(
      adults: adults,
      children: children,
      infants: infants,
      cabin: cabin,
      segments: segments_hash
    )

    Urls::Search::Encoder.new(pricer_form)
  end

  context 'one-way ticket search' do
    before(:all) do
      segments = [['MOW', 'PAR', '12SEP13']]
      @encoder = get_url(segments: segments)
    end

    subject { @encoder }

    its(:valid?) { should be_true }
    its(:url) { should == 'B110MOWPAR12SEP' }
  end

  context 'two-way ticket search' do
    before(:all) do
      segments = [['MOW', 'PAR', '12SEP13'], ['PAR', 'MOW', '17SEP13']]
      @encoder = get_url(segments: segments)
    end

    subject { @encoder }

    its(:valid?) { should be_true }
    its(:url) { should == 'B110MOWPAR12SEPPARMOW17SEP' }
  end

  context 'complex route' do
    before(:all) do
      segments = [
        ['MOW', 'PAR', '12SEP'],
        ['PAR', 'AMS', '17SEP'],
        ['AMS', 'CHC', '18SEP'],
        ['CHC', 'AMS', '20SEP'],
        ['AMS', 'PAR', '30SEP'],
        ['PAR', 'MOW', '12OCT']
      ]
      @encoder = get_url(segments: segments)
    end

    subject { @encoder }

    its(:valid?) { should be_true }
    its(:url) { should == 'B110MOWPAR12SEPPARAMS17SEPAMSCHC18SEPCHCAMS20SEPAMSPAR30SEPPARMOW12OCT' }
  end

  context 'short iatas' do
    before(:all) do
      segments = [['RU', 'US', '12SEP13']]
      @encoder = get_url(segments: segments)
    end

    subject { @encoder }

    its(:valid?) { should be_true }
    its(:url) { should == "B110RU#{filler}US#{filler}12SEP" }
  end
end

