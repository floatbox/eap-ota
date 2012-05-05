#require File.expand_path('../../config/environment', __FILE__)
require './lib/fetch_nested'
require 'benchmark'

n = 200_000
hash = {"foo" => {"bar" => {"baz" => 1}}}

puts "fetching existing key"
Benchmark.bm do |x|
  x.report('normal access     ') { n.times { hash["foo"]["bar"]["baz"] } }
  x.report('fetch nested      ') { n.times { hash.nested("foo.bar.baz") } }
  x.report('fetch nested proxy') { n.times { hash.nested[ "foo.bar.baz" ] } }
end

puts
puts "fetching non existing key"
Benchmark.bm do |x|
  x.report('normal access     ') { n.times { hash["foo"]["bar"]["none"] } }
  x.report('fetch nested      ') { n.times { hash.nested("foo.bar.none") } }
  x.report('fetch nested proxy') { n.times { hash.nested[ "foo.bar.none" ] } }
end
