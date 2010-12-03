namespace :completer do
  desc "regenerate completer dictionary from database"
  task :regen => :environment do
    Completer.new.dump
  end
end

