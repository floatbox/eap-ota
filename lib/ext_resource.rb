module ExtResource
  def self.included klass
    klass.class_eval do
      named_scope :limited, lambda {|limit| {:limit => limit.to_i}}
    end
  end

  def kind
    self.class.to_s.underscore
  end
end
