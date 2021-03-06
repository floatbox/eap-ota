class Amadeus::Poller
  attr_accessor :queue, :processor, :sleep_interval, :retry_interval

  def initialize queue, &block
    @queue = queue
    @processor = block
  end

  def start!
    loop do
      reset_retry
      begin
        queue.each do |message|
          result = processor.call message
          queue.remove_pnr(message.pnr) if result
        end
        sleep sleep_interval
      rescue => e
        with_warning
        increment_retry
        sleep retry_interval
        retry
      end
    end
  end

  def logger
    Rails.logger
  end

  def sleep_interval
    @sleep_interval ||= 5.minutes
  end

  def reset_retry
    self.retry_interval = 0
  end

  def increment_retry
    self.retry_interval += 2.minutes
    logger.info "Retry increased, new value: #{retry_interval / 60} minutes"
  end
end
