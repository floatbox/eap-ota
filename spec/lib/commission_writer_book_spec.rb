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

      example "SVOCDG/AB"
      example "SVOCDG CDGSVO/AB"
      comment "есть проблемы"
      comment "и не одна"
      agent "* Какой-то текст"
      agent "продолжается и здесь"
      subagent "* Какой-то текст со странными правками"
      subagent "продолжается и здесь"
      classes :business, :economy
      subclasses "ABCDEFGH"
      routes "MOW...US/ALL", "MOW-PAR-MOW"
      consolidator "2%"
      blanks "50"
      discount "4%"
      our_markup "1eur"
      ticketing_method "aviacenter"
      tour_code "FOOBAR"
      designator "123"
      check %{
        includes_only(operating_carrier_iatas.first, 'AB HG') and
          includes(city_iatas, 'MOW NYC')
      }
      commission "2%/0.05"

      example "SVOLED/AB"
      important!
      domestic
      no_commission "Катя просила выключить"

      carrier "FV", start_date: "2013-06-30"

      no_commission

      carrier "FV"

      commission "3%/1%"

    END
    book = Commission::Reader.new.read book_string
    Commission::Writer::Book.new(book).write.should == book_string
  end
end
