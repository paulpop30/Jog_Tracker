class TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy]
  # Pundit callbacks
  after_action :verify_authorized, except: [:index]
  after_action :verify_policy_scoped, only: [:index]

  # GET /time_entries
  def index
  if params[:user_id] && current_user.admin?
    @user = User.find(params[:user_id])
    entries = policy_scope(TimeEntry).where(user: @user)
  else
    @user = current_user
    entries = policy_scope(TimeEntry).where(user: @user)
  end

  if session[:filtered_time_entry_ids]
    @time_entries = entries.where(id: session.delete(:filtered_time_entry_ids))
  else
    @time_entries = entries
  end

  # Weekly stats
  @weekly_stats = @time_entries
    .select("DATE_TRUNC('week', date) AS week_start,
             AVG(distance / NULLIF(time_in_seconds, 0) * 3600) AS avg_speed,
             SUM(distance) AS total_distance")
    .group("week_start")
    .order("week_start DESC")
end



  # GET /time_entries/:id
  def show
    authorize @time_entry
  end

  # GET /time_entries/new
  def new
  # If admin and user_id param is present, we're creating for that user
  @user = (current_user.admin? && params[:user_id]) ? User.find(params[:user_id]) : current_user
  @time_entry = @user.time_entries.new
  authorize @time_entry
end

def create
  @user = (current_user.admin? && params[:user_id]) ? User.find(params[:user_id]) : current_user
  @time_entry = @user.time_entries.new(time_entry_params)
  authorize @time_entry

  if @time_entry.save
    redirect_to user_time_entries_path(@user), notice: "Time entry created successfully."
  else
    render :new
  end
end





  # GET /time_entries/:id/edit
  def edit
    @user = @time_entry.user  
    authorize @time_entry
  end

  # PATCH/PUT /time_entries/:id
  def update
    @user = @time_entry.user
    authorize @time_entry

    if @time_entry.update(time_entry_params)
      redirect_to user_time_entries_path(@time_entry.user), notice: "Time entry updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /time_entries/:id
  def destroy
    authorize @time_entry
    user = @time_entry.user
    @time_entry.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to user_time_entries_path(user), notice: "Time entry deleted." }
    end
  end

  # GET /time_entries/weekly_report
  # GET /time_entries/weekly_report
def weekly_report
  authorize TimeEntry, :weekly_report?

  if params[:user_id] && current_user.admin?
    @user = User.find(params[:user_id])
    entries = @user.time_entries
  else
    @user = current_user
    entries = @user.time_entries
  end

  # Apply filters
  entries = entries.where("date >= ?", params[:from_date]) if params[:from_date].present?
  entries = entries.where("date <= ?", params[:to_date]) if params[:to_date].present?

  @weekly_stats = entries
    .where("time_in_seconds > 0")
    .select(
      "DATE_TRUNC('week', date) AS week_start,
       ROUND(AVG(distance / NULLIF(time_in_seconds,0) * 3600)::numeric, 2) AS avg_speed,
       ROUND(SUM(distance)::numeric, 2) AS total_distance"
    )
    .group("week_start")
    .order("week_start")
end


  # GET /time_entries/filter
# GET /time_entries/filter or /users/:user_id/time_entries/filter
def filter
  if params[:user_id] && current_user.admin?
    @user = User.find(params[:user_id])
    @time_entries = @user.time_entries
  else
    @user = current_user
    @time_entries = @user.time_entries
  end
  authorize TimeEntry
end

# POST /time_entries/apply_filter or /users/:user_id/time_entries/apply_filter
def apply_filter
  if params[:user_id] && current_user.admin?
    @user = User.find(params[:user_id])
    entries = @user.time_entries
  else
    @user = current_user
    entries = @user.time_entries
  end

  authorize TimeEntry, :apply_filter?

  from_date = params[:from_date]
  to_date   = params[:to_date]

  @time_entries = entries.where(date: from_date..to_date)
  session[:filtered_time_entry_ids] = @time_entries.pluck(:id)

  # Redirect to the correct page depending on user
  if params[:user_id] && current_user.admin?
    redirect_to user_time_entries_path(@user)
  else
    redirect_to time_entries_path
  end
end






  private

  def set_time_entry
    @time_entry = TimeEntry.find(params[:id])
  end

  def time_entry_params
    permitted = [:date, :distance, :time_in_seconds, :location ]
    permitted << :user_id if current_user.admin? # Admins can assign entries
    params.require(:time_entry).permit(permitted)
  end
end
