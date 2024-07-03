class UpdateFollowUpStatuses < ActiveRecord::Migration[7.1]
  def change
    FollowUp.where(status: "multiple_rdvs_cancelled").find_each(&:save!)
  end
end
