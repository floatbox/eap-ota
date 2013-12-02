class ContextBuilder
  def initialize options = {}
    @options = options
    @options[:partner] = Partner.anonymous
    @options[:robot] = false
    @frozen = false
  end

  def build!
    @frozen = true
    context = Context.new @options.slice(:partner, :robot, :deck_user)
    Rails.logger.info "Initialized context: #{context.inspect}"
    context
  end

  def robot= value
    raise if @frozen
    @options[:robot] = value
  end

  def partner= partner_or_code
    raise if @frozen
    @options[:partner] = case partner_or_code
    when Partner
      partner_or_code
    else
      # Partner[] для несуществующих кодов возвращает Partner.anonymous
      Partner[partner_or_code]
    end
  end

  def deck_user= user
    raise if @frozen
    @options[:deck_user] = user
  end
end
