class ContextBuilder
  def initialize options = {}
    @options = options
    @options[:partner] = Partner.anonymous
    @options[:robot] = false
  end

  def build!
    context = Context.new @options.slice(:partner, :robot, :deck_user)
    Rails.logger.info "Initialized context: #{context.inspect}"
    context
  end

  def robot= value
    @options[:robot] = value
  end

  def partner= partner_or_code
    @options[:partner] = case partner_or_code
    when Partner
      partner_or_code
    else
      # Partner[] для несуществующих кодов возвращает Partner.anonymous
      Partner[partner_or_code]
    end
  end

  def deck_user= user
    @options[:deck_user] = user
  end
end
