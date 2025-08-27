# app/controllers/api/time_entries_controller.rb
class Api::TimeEntriesController < Api::BaseController
  skip_after_action :verify_authorized, only: [:index, :weekly_report]
  before_action :set_time_entry, only: %i[show update destroy]

  def index
    time_entries = policy_scope(TimeEntry)

    if params[:from_date].present?
      time_entries = time_entries.where("date >= ?", params[:from_date])
    end
    if params[:to_date].present?
      time_entries = time_entries.where("date <= ?", params[:to_date])
    end

    render json: time_entries.as_json(methods: :average_speed), status: :ok
  end

  def show
    authorize @time_entry
    render json: @time_entry.as_json(methods: :average_speed), status: :ok
  end

  def create
    time_entry = current_api_user.time_entries.build(time_entry_params)
    authorize time_entry

    if time_entry.save
      render json: time_entry, status: :created
    else
      render json: { errors: time_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @time_entry
    if @time_entry.update(time_entry_params)
      render json: @time_entry, status: :ok
    else
      render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @time_entry
    @time_entry.destroy
    head :no_content
  end

  def weekly_report
    authorize TimeEntry, :weekly_report?

    entries = policy_scope(TimeEntry)
    entries = entries.where("date >= ?", params[:from_date]) if params[:from_date].present?
    entries = entries.where("date <= ?", params[:to_date]) if params[:to_date].present?

    weekly_stats = entries
      .where("time_in_seconds > 0")
      .select(
        "DATE_TRUNC('week', date) AS week_start,
         ROUND(AVG(distance / NULLIF(time_in_seconds,0) * 3600)::numeric, 2) AS avg_speed,
         ROUND(SUM(distance)::numeric, 2) AS total_distance"
      )
      .group("week_start")
      .order("week_start")

    render json: weekly_stats, status: :ok
  end

  private

  def set_time_entry
    @time_entry = TimeEntry.find(params[:id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:date, :distance, :time_in_seconds)
  end
end
