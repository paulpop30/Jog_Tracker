class ApplicationController < ActionController::Base
  include Pundit

  # Only run these for our own controllers that are not Devise
  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Skip Pundit for Devise and any admin controllers
  def skip_pundit?
    devise_controller? || params[:controller].start_with?('admin/')
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end

  # After login, send all users (including admins) to their own time entries
  def after_sign_in_path_for(resource)
  weekly_report_time_entries_path
end

  def after_sign_up_path_for(resource)
    # You can also send new signups directly to their entries if you want
    user_time_entries_path(resource)
  end
end
