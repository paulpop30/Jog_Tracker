class ReportPolicy < Struct.new(:user, :report)
  def weekly_summary?
    user.present?
  end
end
