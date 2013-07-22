# encoding: utf-8
require 'spec_helper'

describe Urls::Search::Encoder do

  let(:filler) { Urls::Search::FILLER_CHARACTER }

  def get_url(params={})

    segments_hash = {}
    params[:segments].each_with_index do |segment, index|
      from, to, date = segment
      segments_hash[index.to_s] = {
        from: from,
        to: to,
        date: date
      }
    end

    pricer_form = PricerForm.new(
      adults: params[:adults] || 1,
      children: params[:children] || 0,
      infants: params[:infants] || 0,
      cabin: params[:cabin] || 'Y',
      segments: segments_hash
    )

    pricer_form.encode_url
  end

  specify 'one-way ticket search' do
    segments = [['MOW', 'PAR', '120913']]
    url = get_url(segments: segments)
    url.should == 'MOW-PAR-Sep12'
  end

  specify 'two-way ticket search' do
    segments = [['MOW', 'PAR', '120913'], ['PAR', 'MOW', '170913']]
    url = get_url(segments: segments)
    url.should == 'MOW-PAR-Sep12-Sep17'
  end

  specify 'ground segment search' do
    segments = [['MOW', 'RTM', '120913'], ['AMS', 'MOW', '170913']]
    url = get_url(segments: segments)
    url.should == 'MOW-RTM-Sep12-AMS-MOW-Sep17'
  end

  specify 'complex route' do
    segments = [
      ['MOW', 'PAR', '120913'],
      ['PAR', 'AMS', '170913'],
      ['AMS', 'CHC', '180913'],
      ['CHC', 'AMS', '200913'],
      ['AMS', 'PAR', '300913'],
      ['PAR', 'MOW', '121013']
    ]
    url = get_url(segments: segments)
    url.should == 'MOW-PAR-Sep12-PAR-AMS-Sep17-AMS-CHC-Sep18-CHC-AMS-Sep20-AMS-PAR-Sep30-PAR-MOW-Oct12'
  end

  specify 'short iatas' do
    segments = [['RU', 'US', '120913']]
    url = get_url(segments: segments)
    url.should == "RU-US-Sep12"
  end

  specify 'business class' do
    segments = [['RU', 'US', '120913']]
    url = get_url(segments: segments, cabin: 'C')
    url.should == "RU-US-Sep12-business"
  end

  specify 'passengers' do
    segments = [['MOW', 'PAR', '120913']]
    url = get_url(segments: segments, adults: 2, infants: 1)
    url.should == "MOW-PAR-Sep12-2adults-infant"
  end

  specify 'more passengers' do
    segments = [['MOW', 'PAR', '120913']]
    url = get_url(segments: segments, adults: 1, children: 2)
    url.should == "MOW-PAR-Sep12-adult-2children"
  end
end

