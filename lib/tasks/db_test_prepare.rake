# наш код с пустой базой работать не будет.
# cat dump.sql | rails db test
Rake::Task['db:test:prepare'].clear
task 'db:test:prepare' do
  puts "Skipping clearing of test database. Make sure you've loaded an appropriate dump into it."
end
