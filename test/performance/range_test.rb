#require File.expand_path('../../config/environment', __FILE__)
require 'benchmark'

n = 200

puts "when with range"
Benchmark.bm do |x|
  x.report('case string ') { n.times {
    time = '1800'
    case time
    when ('0000'...'0500')
      0 #'night'
    when ('0500'...'1200')
      1 #'morning'
    when ('1200'...'1700')
      2 #'day'
    when ('1700'...'2400')
      3 #'evening'
    end
    } }
  
  x.report('case int    ') { n.times { 
    time = '1800'
    case
    when time < '0500';  0 # night
    when time < '1200';  1 # morning
    when time < '1700';  2 # day
    else                 3 # evening
    end
    } }

  x.report('if          ') { n.times { 
    time = '1800'.to_i
    if (0 < time && time > 500)
      0 #'night'
    elsif (500 < time && time > 1200)
      1 #'morning'
    elsif (1200 < time && time > 1700)
      2 #'day'
    else
      3 #'evening'
    end
    } }
end

