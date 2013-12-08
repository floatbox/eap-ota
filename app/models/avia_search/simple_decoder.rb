class AviaSearch::SimpleDecoder

  # FIXME переделать в builder тоже? с отдельной валидацией, мейби.
  PARAMS = %W[
    from to
    from1 from2 from3 from4 from5 from6
    to1 to2 to3 to4 to5 to6
    date1 date2 date3 date4 date5 date6
    adults children infants cabin
  ]

  def decode(args)
    args = args.dup.stringify_keys!

    args["from1"] ||= args["from"]
    args["to1"] ||= args["to"]
    # можно не указывать обе точки второго сегмента для туда-обратно
    args["from2"] ||= args["to1"]
    args["to2"] ||= args["from1"]
    # можно не указывать fromN для неразрывных маршрутов
    ("date2".."date6").zip("from2".."from6", "to1".."to5").each do |date, from, to|
      args[from] ||= args[to] if args[date]
    end
    args.delete_if {|k, v| v.blank? }

    # wrong_parameters = args.keys - PARAMS
    # unless wrong_parameters.empty?
    #   raise ArgumentError, "Unknown parameter(s) - \"#{wrong_parameters.join(', ')}\""
    # end
    lack_of_parameters = %W[from1 to1 date1] - args.keys
    unless lack_of_parameters.empty?
      raise ArgumentError, "Lack of required parameter(s)  - \"#{lack_of_parameters.join(', ')}\""
    end

    segments = []
    (1..6).each do |i|
      # map и break не дружат
      break unless args["date#{i}"]
      segments << AviaSearchSegment.new(
        from: args["from#{i}"], to: args["to#{i}"], date: args["date#{i}"]
      )
    end

    adults = (args["adults"] || 1).to_i
    children = args["children"].to_i
    infants = args["infants"].to_i
    cabin = args["cabin"]

    AviaSearch.new :segments => segments,
      :adults => adults, :children => children, :infants => infants, :cabin => cabin
  end

end
