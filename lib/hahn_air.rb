#!/usr/bin/env ruby
# encoding: utf-8
require 'httparty'
class HahnAir
  include HTTParty
  format :json
  base_uri 'https://api.hahnair.com/'

  # sample response
  # @example
  #   [{"code":"EK","name":"Emirates","gdses":["ama","gal","sab"],"remarks":""},
  #    {"code":"LH","name":"Lufthansa","gdses":["ama","gal","sab"],"remarks":""},
  #    {"answer":"YES"},
  #    {"matching":["ama","gal","sab"]}]

  def self.allows? carriers
    carriers = Array(carriers)
    resp = get("/api/1-eviterra/quickcheck/RU/#{carriers.join('/')}").parsed_response
    if resp.empty?
      log 'Unknown carriers:', carriers
      return false
    end
    answer = resp.find {|h| h['answer']}
    matching = resp.find {|h| h['matching']}
    result = answer['answer'] == 'YES' && matching['matching'].include?('ama')
    log result, carriers
    result
  rescue
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

end

if $0 == __FILE__
  require 'pp'
  pp HahnAir.allows?(ARGV)
end
