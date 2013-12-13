#!/usr/bin/env ruby
# encoding: utf-8
require 'httparty'
require 'nokogiri'

class HahnAir
  class ParseError < ArgumentError; end
  include HTTParty
  format :html
  base_uri 'https://www.hahnair.com'
  headers({
    'Referer' => 'https://www.hahnair.com/en/ticketing/home',
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.55 Safari/537.36'
  })

  # sample response
  # @example
  #   [{"code":"EK","name":"Emirates","gdses":["ama","gal","sab"],"remarks":""},
  #    {"code":"LH","name":"Lufthansa","gdses":["ama","gal","sab"],"remarks":""},
  #    {"answer":"YES"},
  #    {"matching":["ama","gal","sab"]}]

  def self.allows? carriers
    carriers = Array(carriers)
    resp = get("/service/html/quickcheck/RU/#{carriers.join('/')}").parsed_response
    result = if carriers.count == 1
      parse_single resp
    else
      parse_multiple resp
    end

    log result, carriers
    result
  rescue
    with_warning
    log $!.message, carriers
    nil
  end

  def self.logger
    @logger ||= ActiveSupport::BufferedLogger.new('log/hahnair.log') rescue false
  end

  def self.log message, carriers
    if logger
      logger.info(message.inspect + ' (' + carriers.sort.join(' ') + ')')
    end
  end

  private

  def self.parse_single doc
    doc = Nokogiri::HTML(doc)
    raise HahnAir::ParseError if doc.css('.table-quickcheck>tbody tr').empty?
    result = doc.css('.table-quickcheck>tbody tr').select do |row|
      row.css('img[alt="Amadeus"]').present? && row.css('.text-success').present?
    end

    result.count > 0
  end

  def self.parse_multiple doc
    doc = Nokogiri::HTML(doc)
    raise HahnAir::ParseError if doc.css('.table-quickcheck-yesno').empty?
    doc.css('.table-quickcheck-yesno.text-success').present?
  end
end

if $0 == __FILE__
  require 'pp'
  pp HahnAir.allows?(ARGV)
end
