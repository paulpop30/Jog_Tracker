class HomeController < ApplicationController
  # Skip Pundit authorization for all actions in this controller
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def index
    if user_signed_in?
      redirect_to time_entries_path
    end
  end
end
