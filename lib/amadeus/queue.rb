class Amadeus::Queue
  attr_accessor :queue_id, :office

  def initialize queue_id, office = Conf.amadeus.default_office
    # queue_id может быть с категорией и без, но лучше с ней — иначе каунт ломается
    # пример: 8C0
    @queue_id = queue_id
    @office   = office
  end

  def each
    raise ArgumentError.new('Block required') unless block_given?

    Amadeus.session(office) do |amadeus|
      begin
        response = amadeus.cmd queue_open_cmd; log response
        message = Amadeus::Queue::Message::PNR.new response
        loop do
          log message
          raise Amadeus::Error if message.error?
          yield message
          break if message.queue_end?
          message = queue_next(amadeus)
        end
      ensure
        amadeus.cmd queue_close_cmd
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

  private

  def logger
    Rails.logger
  end

  def log message
    logger.info "[#{queue_id}] #{message}"
  end

  def queue_next amadeus
    log 'Next message'
    response = amadeus.cmd queue_next_cmd
    log response
    Amadeus::Queue::Message::PNR.new response
  end

  def queue_open_cmd
    "QS#{queue_id}"
  end

  def queue_count_cmd
    "QC#{queue_id}"
  end

  def queue_next_cmd
    'QN'
  end

  def queue_close_cmd
    "QI"
  end
end

module Amadeus::Queue::Message
  class PNR
    attr_accessor :pnr, :queue_end, :error, :raw_message

    PNR = /\n[A-Z0-9\/]+\s+[A-Z0-9\/]+\s+[A-Z0-9\/]+\s+([A-Z0-9]{6})\n/
    QUEUE_END = /\*\* QUEUE CYCLE COMPLETE \*\*/

    def initialize message
      @raw_message = message
      parse_message
    end

    def queue_end?
      !!queue_end
    end

    def error?
      !!error
    end

    def to_s
      "<Amadeus::Queue::Message::PNR pnr: #{pnr} queue_end: #{queue_end} error: #{error}"
    end

    def inspect
      [to_s, raw_message].join("\n")
    end

    private

    def parse_message
      if raw_message =~ QUEUE_END
        @queue_end = true
      end

      if match = raw_message.match(PNR)
        @pnr = match.captures.first
      else
        @error = true
        @queue_end = true
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
      @count = raw_message.lines.to_a[3].split(/\s+/)[2].to_i
    end
  end
end
