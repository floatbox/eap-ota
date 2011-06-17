# encoding: utf-8
task :conf => 'conf:show'
namespace :conf do
  desc "display important current settings"
  task :show => :environment do
    puts "amadeus enabled:  #{Conf.amadeus.enabled}"
    puts "amadeus host:     #{Conf.amadeus.endpoint}"
    puts "sirena enabled:  #{Conf.sirena.enabled}"
    puts "sirena host:     #{Conf.sirena.host}"
    puts "sirena port:     #{Conf.sirena.port}"
    puts "payture host:    #{Conf.payture.host}"
  end
end
