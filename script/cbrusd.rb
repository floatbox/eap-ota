require 'net/http'
require 'rexml/document'
require 'date'
include REXML

cbr_today = (DateTime.now).strftime("%d/%m/%Y") #дата в нужном для cbr формате
cbr_tomorrow = (DateTime.now + 1).strftime("%d/%m/%Y")

today_xml = Net::HTTP.get_response("www.cbr.ru", "/scripts/XML_daily.asp?date_req=#{cbr_today}")
tomorrow_xml =  Net::HTTP.get_response("www.cbr.ru", "/scripts/XML_daily.asp?date_req=#{cbr_tomorrow}")

today_doc = Document.new today_xml.read_body
today_root = today_doc.root

tomorrow_doc = Document.new tomorrow_xml.read_body
tomorrow_root = tomorrow_doc.root

today_date = today_root.attributes["Date"]
today_usd = today_root.elements["Valute[@ID='R01235']/Value"].get_text.to_s.gsub(",", ".")

tomorrow_date = tomorrow_root.attributes["Date"]
tomorrow_usd = tomorrow_root.elements["Valute[@ID='R01235']/Value"].get_text.to_s.gsub(",", ".")

file = File.new("currencies.txt", "w+")
file.puts("cbr:")
file.puts("  usd:")
file.puts("    #{(DateTime.now).strftime("%F")}: #{today_usd}")
file.puts("    #{(DateTime.now + 1).strftime("%F")}: #{tomorrow_usd}")


#puts eur = root.elements["Valute[@ID='R01239']/Value"].get_text
#puts uah = root.elements["Valute[@ID='R01720']/Value"].get_text
#puts byr = root.elements["Valute[@ID='R01090']/Value"].get_text.value