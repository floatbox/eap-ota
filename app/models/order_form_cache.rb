# encoding: utf-8
# временная "таблица" в монго для промежуточного хранения полей в OrderForm
# TODO 
class OrderFormCache
  include Mongoid::Document
  include Mongoid::Timestamps

  field :recommendation_yml, :type => String
  field :people_count
  field :query_key, :type => String
  field :partner, :type => String
  field :marker, :type => String
  field :price_with_payment_commission, :type => Float

  def recommendation= rec
    rec = rec.dup
    rec.reset_commission!
    self.recommendation_yml = YAML.dump(rec)
  end

  def recommendation
    recommendation_yml && Recommendation.from_yml(recommendation_yml)
  end

  def people_count
    # возвращается почему-то BSON::OrderedHash
    Hash[ super || {} ].symbolize_keys
  end

end
