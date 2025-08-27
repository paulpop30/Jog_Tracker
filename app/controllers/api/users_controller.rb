# app/controllers/api/users_controller.rb
class Api::UsersController < Api::BaseController
  before_action :set_user, only: %i[show update destroy]

  def index
    users = policy_scope(User)
    render json: users, status: :ok
  end

  def show
    authorize @user
    render json: @user, status: :ok
  end

  def create
    user = User.new(user_params)
    authorize user
    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @user
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  # Strong parameters for creating/updating users.
  # Adjust permitted params as per your User model attributes.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
