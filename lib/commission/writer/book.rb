# encoding: utf-8
class Commission::Writer::Book

  def initialize(book)
    @book = book
  end

  def write
    book_string = ""
    @book.pages.each do |page|
      book_string << Commission::Writer::Page.new(page).write
    end
    book_string
  end

end
