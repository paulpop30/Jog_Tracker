# spec/models/time_entry_spec.rb
require 'rails_helper'

RSpec.describe TimeEntry, type: :model do
  subject { described_class.new(date: Date.today, distance: 5.0, time_in_seconds: 1800, user: User.new) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is invalid without a distance" do
    subject.distance = nil
    expect(subject).to_not be_valid
  end
end
