FactoryBot.define do
  factory :time_entry do
    user { nil }
    date { "2025-08-10" }
    distance { 1.5 }
    time_in_seconds { 1 }
  end
end
