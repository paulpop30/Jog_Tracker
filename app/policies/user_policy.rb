# app/policies/user_policy.rb
class UserPolicy < ApplicationPolicy
  def index?
    user.admin? || user.user_manager?
  end

  def show?
    return false unless user.present?

    if user.admin?
      true
    elsif user.user_manager?
      !record.admin? # managers cannot view admin accounts
    else
      record == user # regulars can only view themselves
    end
  end

  def create?
    if user.admin?
      true
    elsif user.user_manager?
      true # managers can create regular users
    else
      false
    end
  end

  def new?
    create?
  end

  def update?
    return false unless user.present?

    if user.admin?
      true
    elsif user.user_manager?
      !record.admin? # managers cannot update admin accounts
    else
      record == user # regulars can only update their own account
    end
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user.present?

    if user.admin?
      true
    elsif user.user_manager?
      !record.admin? # managers cannot destroy admin accounts
    else
      false
    end
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.user_manager?
        scope.where(admin: [false, nil]) # managers only see non-admins
      else
        scope.where(id: user.id) # regulars only see themselves
      end
    end
  end
end
