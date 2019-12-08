# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    if (user != nil && (user.has_role? :admin))
      can :manage, :all
      can :read, :all
    
    else
      can :read, :all
      can [:index_json], Notice
    end
  end
end
