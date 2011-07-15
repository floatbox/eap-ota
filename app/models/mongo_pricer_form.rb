class MongoPricerForm
  include Mongoid::Document
  include Mongoid::Timestamps
  include CopyAttrs
  store_in :pricer_forms
  field :adults, :type => Integer, :default => 1
  field :children, :type => Integer, :default => 0
  field :infants, :type => Integer, :default => 0
  field :complex_to
  field :cabin
  field :query_key
  field :partner
  field :use_count, :type => Integer, :default => 1
  embeds_many :segments, :class_name => 'MongoPricerForm::Segment'

  def pricer_form= pf
    copy_attrs pf, self,
      :adults,
      :children,
      :infants,
      :complex_to,
      :cabin,
      :query_key,
      :partner
    self.segments = pf.form_segments.map do |s|
      Segment.new(:from => s.from, :to => s.to, :date => s.date)
    end
  end

  class Segment
    include Mongoid::Document
    embedded_in :form, :class_name => 'MongoPricerForm'
    field :from
    field :to
    field :date
  end
end

