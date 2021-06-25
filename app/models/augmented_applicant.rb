# this class is a model representing an applicant along with its rdv solidarites
# user infos

class AugmentedApplicant
  def initialize(applicant, rdv_solidarites_user)
    @applicant = applicant
    @rdv_solidarites_user = rdv_solidarites_user
  end

  def as_json(_opts = {})
    # we want to send dates as strings
    {
      uid: @applicant.uid,
      created_at: @rdv_solidarites_user.created_at&.to_date&.strftime("%m/%d/%Y"),
      invited_at: @rdv_solidarites_user.invited_at&.to_date&.strftime("%m/%d/%Y")
    }
  end
end
