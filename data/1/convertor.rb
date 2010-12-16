#!/usr/bin/env ruby -Ku
require 'csv'
require 'rubygems'
require 'every'

ac, sc = [['agent-commission.csv', 4], ['subagent-commission.csv', 3]].collect do |file, col|
  a = CSV.open(file, 'r', ?\t).to_a
  a = a.take_while(&:any?)
  a = a.every.values_at(2,1,col)
  a.each_cons(2) do |x, y|
    if y[0].nil?
      x[-1] << "\n" << y[-1]
    end
  end
  a.delete_if {|x| x[0].nil? }
  a.flatten.each {|x| x.strip!}
  a
end

def value(string)
  string = string.to_s.gsub ',', '.'
  case string
  when /((\d+\.)?\d+) ?\%/
    #$2 ? "#{$1}%" : "#{$1}.0%"
    "#{$1}%"
  when /((\d+\.)?\d+) ?руб/
    $1
  when /((\d+\.)?\d+) ?коп/
    ($1.to_f / 100).to_s
  when /((\d+\.)?\d+) ?(eur|евр)/
    "#{$1}eur"
  else
    nil
  end
end

common_carriers = ac.every.first & sc.every.first


puts "class Commission"
puts "include CommissionRules"
puts

output = CSV.open 'result.csv','w', ?;
common_carriers.sort.each do |carrier|
  results = []
  an, at = ac.assoc(carrier)[1,2]
  sn, st = sc.assoc(carrier)[1,2]

  puts "carrier #{carrier.inspect}, #{an.inspect}"
  puts "########################################"
  puts

  atr = at.split(/ *\n */)
  str = st.split(/ *\n */)
  [atr.size,str.size].max.times do
    al = atr.shift
    sl = str.shift
    av = value(al)
    sv = value(sl)
    if  !(av && sv) && results[-1]
      results[-1][:agent] << al if al && (al != '')
      results[-1][:subagent] << sl if sl && (sl != '')
    else
      results << {
        :carrier => carrier, :name => an, :commission => "#{av}/#{sv}", :agent => [al], :subagent => [sl]
      }
    end

    if al =~ /interline/i
      if al =~ /не прописан/
        results[-1][:interline] = :no
      elsif al =~/без участ/
        results[-1][:interline] = :without
      else
        results[-1][:interline] = :yes
      end
    end

  end
  results.each do |result|
    output << [result[:carrier], result[:name], result[:commission], result[:agent].join("\n"), result[:subagent].join("\n"), result[:interline]]

    result[:agent].each do |ags|
      puts "agent    #{ags.inspect}"
    end
    result[:subagent].each do |sgs|
      puts "subagent #{sgs.inspect}"
    end
    if result[:interline]
      puts "interline #{result[:interline].inspect}"
    end
    puts "commission #{result[:commission].inspect}"
    puts
  end

end
output.close

puts
puts "end"
__END__
  an, at = ac.assoc(carrier)[1,2]
  sn, st = sc.assoc(carrier)[1,2]
  puts <<"END"
# #{an} / #{sn}
carrier "#{carrier}"

# agent:
# #{at.split("\n").join("\n# ")}

# subagent:
# #{st.split("\n").join("\n# ")}

END
end

