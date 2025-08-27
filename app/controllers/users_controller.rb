class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # Pundit callbacks
  after_action :verify_authorized, except: [:index]
  after_action :verify_policy_scoped, only: [:index]

  #skip_before_action :authenticate_user!, only: [:show]
  #skip_after_action :verify_authorized, only: [:show]

  def index
    @users = policy_scope(User)
  end

  def show
    authorize @user
    @time_entries = @user.time_entries || []
    #@user = User.find(params[:id])
    #@time_entries = @user.time_entries || []
    #render json: @user, include: :time_entries
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(user_params)
      redirect_to users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to users_path, notice: "User deleted successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = [:email, :role]
    # Only allow password if present (edit without changing password allowed)
    permitted += [:password, :password_confirmation] if params[:user][:password].present?
    params.require(:user).permit(permitted)
  end
end
