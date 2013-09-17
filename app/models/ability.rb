class Ability
  include CanCan::Ability

  # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  def initialize(user)
    user.roles.each do |role|
      send role if respond_to? role
    end
    # defaults
    can :read, :all
    can :update, DeckUser, id: user.id
  end

  def admin
    can :manage, :all
  end
end
