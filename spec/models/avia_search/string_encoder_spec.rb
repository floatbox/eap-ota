# encoding: utf-8
require 'spec_helper'

describe AviaSearch::StringEncoder do

  def encode(params={})

    segments = params[:segments].map do |segment|
      from, to, date = segment
      AviaSearchSegment.new(from: from, to: to, date: date)
    end

    avia_search = AviaSearch.new(
      adults: params[:adults] || 1,
      children: params[:children] || 0,
      infants: params[:infants] || 0,
      cabin: params[:cabin] || 'Y',
      segments: segments
    )

    # Правильнее было бы AviaSearch::StringEncoder.new.encode(...),
    # но так тест дает больше пользы
    avia_search.to_s
  end

  specify 'one-way ticket search' do
    segments = [['MOW', 'PAR', '120913']]
    encode(segments: segments).should == 'MOW-PAR-12Sep'
  end

  specify 'two-way ticket search' do
    segments = [['MOW', 'PAR', '120913'], ['PAR', 'MOW', '170913']]
    encode(segments: segments).should == 'MOW-PAR-12Sep-17Sep'
  end

  specify 'ground segment search' do
    segments = [['MOW', 'RTM', '120913'], ['AMS', 'MOW', '170913']]
    encode(segments: segments).should == 'MOW-RTM-12Sep-AMS-MOW-17Sep'
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
    encode(segments: segments).should == 'MOW-PAR-12Sep-PAR-AMS-17Sep-AMS-CHC-18Sep-CHC-AMS-20Sep-AMS-PAR-30Sep-PAR-MOW-12Oct'
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
    encode(segments: segments).should == 'MOW-PAR-12Sep-PAR-AMS-17Sep-RTM-CHC-18Sep-CHC-AMS-20Sep-AMS-PAR-30Sep-PAR-MOW-12Oct'
  end

  specify 'short iatas' do
    segments = [['RU', 'US', '120913']]
    encode(segments: segments).should == "RU-US-12Sep"
  end

  specify 'business class' do
    segments = [['RU', 'US', '120913']]
    encode(segments: segments, cabin: 'C').should == "RU-US-12Sep-business"
  end

  specify 'passengers' do
    segments = [['MOW', 'PAR', '120913']]
    encode(segments: segments, adults: 2, infants: 1).should == "MOW-PAR-12Sep-2adults-infant"
  end

  specify 'more passengers' do
    segments = [['MOW', 'PAR', '120913']]
    encode(segments: segments, adults: 1, children: 2).should == "MOW-PAR-12Sep-adult-2children"
  end
end

