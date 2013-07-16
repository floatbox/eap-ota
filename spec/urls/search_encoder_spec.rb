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
        date: date
      }
    end

    pricer_form = PricerForm.new(
      adults: adults,
      children: children,
      infants: infants,
      cabin: cabin,
      segments: segments_hash
    )

    pricer_form.encode_url
  end

  specify 'one-way ticket search' do
    segments = [['MOW', 'PAR', '120913']]
    url = get_url(segments: segments)
    url.should == 'B110MOWPAR12SEP'
  end

  specify 'two-way ticket search' do
    segments = [['MOW', 'PAR', '120913'], ['PAR', 'MOW', '170913']]
    url = get_url(segments: segments)
    url.should == 'B110MOWPAR12SEPPARMOW17SEP'
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
    url.should == 'B110MOWPAR12SEPPARAMS17SEPAMSCHC18SEPCHCAMS20SEPAMSPAR30SEPPARMOW12OCT'
  end

  specify 'short iatas' do
    segments = [['RU', 'US', '120913']]
    url = get_url(segments: segments)
    url.should == "B110RU#{filler}US#{filler}12SEP"
  end
end

