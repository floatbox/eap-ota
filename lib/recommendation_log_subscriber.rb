# логит рекомендации в кратком и "CommandCryptic" виде.
# FIXME
#
# сейчас применяем только к амадеусу, для разбора интерлайнов
class RecommendationLogSubscriber < ActiveSupport::LogSubscriber

  include ActiveSupport::Benchmarkable

  cattr_accessor :cryptic_file do
    open(Rails.root + 'log/rec_cryptic.log', 'a').tap { |fh| fh.sync = true }
  end

  cattr_accessor :short_file do
    open(Rails.root + 'log/rec_short.log', 'a').tap { |fh| fh.sync = true }
  end

  def amadeus_merged(event)
    benchmark 'log_examples' do
      log_examples(event.payload[:recommendations])
    end
  end

  private

    def log_examples(recommendations)
      recommendations.each do |r|
        r.variants.each do |v|
          cryptic_file.puts r.cryptic(v)
        end
        short_file.puts r.short
      end
    end

  attach_to :mux
end
