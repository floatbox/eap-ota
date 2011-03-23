if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Rails.logger.info "First random number: #{rand}"
    srand
    Rails.logger.info "Second random number: #{rand}"
  end
end

