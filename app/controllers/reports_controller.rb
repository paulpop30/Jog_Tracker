class ReportsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def weekly_summary
    authorize :report, :weekly_summary?

    @weekly_data = TimeEntry
      .where(user: current_user)
      .group("DATE_TRUNC('week', date)")
      .select(
        "DATE_TRUNC('week', date) AS week_start,
         AVG(distance / (time_in_seconds / 3600.0)) AS avg_speed,
         AVG(distance) AS avg_distance"
      )
      .order("week_start DESC")

    respond_to do |format|
      format.html
      format.json { render json: @weekly_data }
    end
  end
end
