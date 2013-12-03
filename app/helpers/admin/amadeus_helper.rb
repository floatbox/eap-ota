module Admin::AmadeusHelper
  def linkify_amadeus_text(text)
    text = h(text)
    text.gsub!( /\bMS(\d+)/, '<a style="color:white" href="#MS\1">MS\1</a>' )
    text.gsub!( /\bHE (\w+)/, '<a style="color:white" href="\1">HE \1</a>' )
    blank_lines = 0
    text = text.lines.each_with_index.map {|l, i|
      blank_lines = l.blank? ? blank_lines + 1 : 0
      line = "<a id=\"MS#{i}\"></a>"
      line += l unless blank_lines > 1
      line
    }.compact.join
    text = "<pre>" + text + "</pre>"
    raw(text)
  end
end
