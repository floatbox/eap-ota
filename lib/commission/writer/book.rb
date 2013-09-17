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

  def write_dir(dir)
    FileUtils.mkdir_p(dir)
    @book.pages.each do |page|
      filename = page.carrier
      filename += '-' + page.ticketing_method.to_s if page.ticketing_method
      filename += '-' + page.start_date.to_s if page.start_date
      filename += '.rb'
      filename = File.join(dir, filename)
      File.open(filename, 'w') do |fh|
        fh << Commission::Writer::Page.new(page).write
      end
    end
  end

end
