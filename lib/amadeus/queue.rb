class Amadeus::Queue
  attr_accessor :queue_id, :office, :logger

  def initialize queue_id, office = Conf.amadeus.default_office
    # queue_id может быть с категорией и без, но лучше с ней — иначе каунт ломается
    # пример: 8C0
    @queue_id = queue_id
    @office   = office
  end

  def each &block
    raise ArgumentError.new('Block required') unless block

    Amadeus.session(office) do |amadeus|
      begin
        response = amadeus.cmd view_queue_cmd; log response
        pnrs = response.each_line.select {|l| l =~ /^\d/}.map do |line|
          msg = Amadeus::Queue::Message::PNR.new line
          raise Amadeus::Error if msg.error?
          msg
        end

        pnrs.each &block
      end
    end
  end

  def count
    log 'Count'
    response = Amadeus.session(office) do |amadeus|
      amadeus.cmd queue_count_cmd
    end; log response
    message = Amadeus::Queue::Message::Count.new(response); log message
    message.count
  end

  def remove_pnr pnr
    log "Removing pnr #{pnr}"
    Amadeus.session(office) do |amadeus|
      amadeus.cmd "qx/#{pnr}/#{queue_id}"
    end
  end

  def logger
    @logger || Rails.logger
  end

  private

  def log message
    logger.info "[#{queue_id}] #{message}"
  end

  def view_queue_cmd
    "QV/#{queue_id}"
  end

  def queue_count_cmd
    "QC#{queue_id}"
  end
end

module Amadeus::Queue::Message
  class PNR
    attr_accessor :raw_message, :pnr, :error

    def initialize message
      @raw_message = message
      parse_message
    end

    def error?
      !!error
    end

    def to_s
      "<Amadeus::Queue::Message::PNR pnr: #{pnr} error: #{error}"
    end

    def inspect
      [to_s, raw_message].join("\n")
    end

    private

    def parse_message
      pnr_string = raw_message.split(/\s+/)[2]
      if pnr_string =~ /^[A-Z0-9]{6}$/
        @pnr = pnr_string
      else
        @error = true
      end
    end
  end

  class Count
    attr_accessor :raw_message
    attr_reader :count

    def initialize message
      @raw_message = message
      parse_message
    end

    def to_s
      "<Amadeus::Queue::Message::Count count: #{count}"
    end

    private

    def parse_message
      @count = begin
        line = raw_message.lines.to_a[3]
        match_data = line.match(/C[0-9 ]+\.D\d+\.\s*(\d+)/)
        match_data.captures.first
      end
    end
  end
end
