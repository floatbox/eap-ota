# encoding: utf-8
require 'spec_helper'

describe Commission::Writer::Book do

  def unindent(string)
    string =~ /^(\s*)/
    indent = $1
    string.gsub(/^(#{indent})/, '')
  end

  it "should write the same as readed" do
    book_string = unindent(<<-END)
      carrier "AB"

      rule 1 do
      ticketing_method "aviacenter"
      agent "2%"
      subagent "0.05"
      discount "4%"
      our_markup "1eur"
      consolidator "2%"
      blanks "50"
      tour_code "FOOBAR"
      designator "123"
      comment "есть проблемы"
      comment "и не одна"
      agent_comment "* Какой-то текст"
      agent_comment "продолжается и здесь"
      subagent_comment "* Какой-то текст со странными правками"
      subagent_comment "продолжается и здесь"
      classes :business, :economy
      subclasses "ABCDEFGH"
      routes "MOW...US/ALL", "MOW-PAR-MOW"
      check %{
        includes_only(operating_carrier_iatas.first, 'AB HG') and
          includes(city_iatas, 'MOW NYC')
      }
      example "SVOCDG/AB"
      example "SVOCDG CDGSVO/AB"
      end

      rule 2 do
      no_commission "Катя просила выключить"
      important!
      domestic
      example "SVOLED/AB"
      end

      carrier "FV", start_date: "2013-10-01", no_commission: "сдулись"

      carrier "FV", start_date: "2013-06-30"

      rule 1 do
      no_commission
      end

      carrier "FV"

      rule 1 do
      agent "3%"
      subagent "1%"
      end

    END
    book = Commission::Reader.new.read book_string
    Commission::Writer::Book.new(book).write.should == book_string
  end
end
