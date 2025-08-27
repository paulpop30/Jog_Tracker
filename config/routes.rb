Rails.application.routes.draw do
  root "home#index" 
  # -------------------------
  # Devise authentication
  # -------------------------
  devise_for :users, path: 'auth', path_names: { sign_in: 'login', sign_out: 'logout' }

  # -------------------------
  # Admin: Users management
  # -------------------------
  resources :users, only: [:index, :new, :create, :edit, :update, :destroy, :show] do
    # Nested time entries for admins managing users
    resources :time_entries, only: [:index, :new, :create, :edit, :update, :destroy], shallow: true do
      collection do
        get :weekly_report   # /users/:user_id/time_entries/weekly_report
        get :filter          # /users/:user_id/time_entries/filter
        post :apply_filter   # /users/:user_id/time_entries/apply_filter
      end
    end
  end

  # -------------------------
  # Current logged-in user's time entries
  # -------------------------
  resources :time_entries, only: [:index, :new, :create, :edit, :update, :destroy, :show] do
    collection do
      get :weekly_report      # /time_entries/weekly_report
      get :filter
      post :apply_filter
      get :report
    end
  end

  # -------------------------
  # Reports
  # -------------------------
  get 'reports/weekly_summary', to: 'reports#weekly_summary'

  # -------------------------
  # API namespace (versioned)
  # -------------------------
 namespace :api, defaults: { format: :json } do
  post 'login', to: 'authentication#login'
  resources :users, only: [:index, :show, :create, :update, :destroy]
  resources :time_entries, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get :weekly_report
    end
  end
end


  # -------------------------
  # Root path
  # -------------------------
  #root to: "time_entries#index"
end
