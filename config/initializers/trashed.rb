if GC.respond_to? :enable_stats
  GC.enable_stats
  require 'trashed'
  require 'trashed/rack/request_logger'
  Eviterra::Application.middleware.use Trashed::Rack::RequestLogger, Rails.logger, Trashed::Metrics.available
end
