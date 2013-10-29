# логит рекомендации в кратком и "CommandCryptic" виде.
# FIXME
#
# сейчас применяем только к амадеусу, для разбора интерлайнов
class RecommendationLogSubscriber < ActiveSupport::LogSubscriber

  include ActiveSupport::Benchmarkable

  cattr_accessor :cryptic_logger do
    ActiveSupport::BufferedLogger.new(Rails.root + 'log/rec_cryptic.log')
  end

  cattr_accessor :short_logger do
    ActiveSupport::BufferedLogger.new(Rails.root + 'log/rec_short.log')
  end

  def amadeus_merged
    benchmark 'log_examples' do
      log_examples(recommendations)
    end
  end

  private

    def log_examples(recommendations)
      recommendations.each do |r|
        r.variants.each do |v|
          cryptic_logger.info r.cryptic(v)
        end
        short_logger.info r.short
      end
    end

  attach_to :mux
end
