namespace :migrate do
  task :cities => :environment do
    require 'find_each_with_progress'
    new_cities = 0
    Airport.find_each_with_progress 'making cities' do |a|
      city = City.find_or_create_by_name_en(a.city_en)

      new_cities += 1 if city.new_record?

      city.update_attributes!(
        :name_ru => a.city_ru,
        :region_ru => a.region_ru,
        :country_en => a.country
      )
      a.city = city
      a.save
    end
    puts "cities count: #{City.count}"
    puts "new cities: #{new_cities}"

  end
end
