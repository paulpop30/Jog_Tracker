class TimeEntry < ApplicationRecord
  belongs_to :user

  validates :date, :distance, :time_in_seconds, presence: true
  validates :distance, numericality: { greater_than: 0 }
  validates :time_in_seconds, numericality: { greater_than: 0 }

  def average_speed
    (distance / (time_in_seconds / 3600.0)).round(2) # km/h
  end
end
