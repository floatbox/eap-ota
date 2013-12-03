# encoding: utf-8
task :conf => 'conf:show'
namespace :conf do
  desc "display important current settings"
  task :show => :environment do
    puts "amadeus enabled:  #{Conf.amadeus.enabled}"
    puts "amadeus host:     #{Conf.amadeus.endpoint}"
    puts "payture host:    #{Conf.payture_alfa.host}"
  end
end
