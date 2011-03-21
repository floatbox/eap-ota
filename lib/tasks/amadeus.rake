namespace :amadeus do
  namespace :sessions do
    desc "delete all sessions"
    task :clear => :environment do
      Amadeus::Session.delete_all
    end

    desc "logout stale and start several fresh sessions"
    task :housekeep => :environment do
      Amadeus::Session.housekeep
    end
  end
end


