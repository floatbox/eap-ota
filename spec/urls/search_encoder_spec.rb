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
    url.should == 'MOW-PAR-12Sep'
  end

  specify 'two-way ticket search' do
    segments = [['MOW', 'PAR', '120913'], ['PAR', 'MOW', '170913']]
    url = get_url(segments: segments)
    url.should == 'MOW-PAR-12Sep-17Sep'
  end

  specify 'ground segment search' do
    segments = [['MOW', 'RTM', '120913'], ['AMS', 'MOW', '170913']]
    url = get_url(segments: segments)
    url.should == 'MOW-RTM-12Sep-AMS-MOW-17Sep'
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
    url.should == 'MOW-PAR-12Sep-PAR-AMS-17Sep-AMS-CHC-18Sep-CHC-AMS-20Sep-AMS-PAR-30Sep-PAR-MOW-12Oct'
  end

  specify 'complex route with "segment breaks"' do
    segments = [
      ['MOW', 'PAR', '120913'],
      # прилетаем в Амстердам
      ['PAR', 'AMS', '170913'],
      # вылетаем из Роттердама
      ['RTM', 'CHC', '180913'],
      ['CHC', 'AMS', '200913'],
      ['AMS', 'PAR', '300913'],
      ['PAR', 'MOW', '121013']
    ]
    url = get_url(segments: segments)
    url.should == 'MOW-PAR-12Sep-PAR-AMS-17Sep-RTM-CHC-18Sep-CHC-AMS-20Sep-AMS-PAR-30Sep-PAR-MOW-12Oct'
  end

  specify 'short iatas' do
    segments = [['RU', 'US', '120913']]
    url = get_url(segments: segments)
    url.should == "RU-US-12Sep"
  end

  specify 'business class' do
    segments = [['RU', 'US', '120913']]
    url = get_url(segments: segments, cabin: 'C')
    url.should == "RU-US-12Sep-business"
  end

  specify 'passengers' do
    segments = [['MOW', 'PAR', '120913']]
    url = get_url(segments: segments, adults: 2, infants: 1)
    url.should == "MOW-PAR-12Sep-2adults-infant"
  end

  specify 'more passengers' do
    segments = [['MOW', 'PAR', '120913']]
    url = get_url(segments: segments, adults: 1, children: 2)
    url.should == "MOW-PAR-12Sep-adult-2children"
  end
end

