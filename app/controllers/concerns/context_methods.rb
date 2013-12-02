module ContextMethods
  def context
    @context ||= context_builder.build!
  end

  def context_builder
    @context_builder ||= ContextBuilder.new
  end

  def set_context_partner
    context_builder.partner = cookies[:partner]
  end

  def set_context_robot
    context_builder.robot = true
  end

  def set_context_deck_user
    context_builder.deck_user = current_deck_user
  end
end
