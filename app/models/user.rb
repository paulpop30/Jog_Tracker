class User < ApplicationRecord
  # Devise modules
  has_many :time_entries, dependent: :destroy
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { regular: 0, user_manager: 1, admin: 2 }


  after_initialize do
    self.role ||= :regular if new_record?
  end

  
end
