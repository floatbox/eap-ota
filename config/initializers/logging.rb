# логгинг запросов curl в амадеусе и сирене
require 'our/curl/log_subscriber'
# логгинг в риман
require 'our/curl/monitoring_log_subscriber'
# лог Amadeus::Service
require 'amadeus/log_subscriber'
require 'amadeus/controller_runtime'
# лог xml файлов
require 'amadeus/response_log_subscriber'
# лог рекомендаций
require 'recommendation_log_subscriber'
# счетчики бронирования
require 'order_flow_log_subscriber'
