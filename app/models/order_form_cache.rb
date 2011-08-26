# encoding: utf-8
# временная "таблица" в монго для промежуточного хранения полей в OrderForm
# TODO 
class OrderFormCache
  include Mongoid::Document
  include Mongoid::Timestamps

  field :recommendation_yml, :type => String
  field :people_count
  field :variant_id, :type => String
  field :query_key, :type => String
  field :partner, :type => String

  def recommendation= rec
    self.recommendation_yml = YAML.dump(rec)
  end

  def recommendation
    Recommendation
    Variant
    Flight
    Segment
    recommendation_yml? && YAML.load(recommendation_yml)
  end

  def people_count
    # возвращается почему-то BSON::OrderedHash
    Hash[ super || {} ].symbolize_keys
  end

end
