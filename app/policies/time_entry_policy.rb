class TimeEntryPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user

      if user.admin?
        scope.all
      elsif user.role == "user_manager"
        # managers see all regular users' entries, but not admin entries
        scope.joins(:user).where(users: { admin: [false, nil] })
      else
        # regular users see only their own
        scope.where(user_id: user.id)
      end
    end
  end

  def filter?
    user.admin? || user.role.in?(%w[regular user_manager])
  end

  alias_method :apply_filter?, :filter?

  def weekly_report?
    user.present? # anyone logged in can see their own report
  end

  def show?
    return false unless user.present?

    if user.admin?
      true
    elsif user.role == "user_manager"
      !record.user.admin? # managers cannot view admin entries
    else
      record.user_id == user.id
    end
  end

  def create?
    user.present?
  end

  def update?
    return false unless user.present?

    if user.admin?
      true
    elsif user.role == "user_manager"
      !record.user.admin? # managers cannot edit admin entries
    else
      record.user_id == user.id
    end
  end

  def destroy?
    update? # same rules as update
  end
end
