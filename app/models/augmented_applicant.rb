# this class is a model representing an applicant along with its rdv solidarites
# user infos

class AugmentedApplicant
  def initialize(applicant, rdv_solidarites_user)
    @applicant = applicant
    @rdv_solidarites_user = rdv_solidarites_user
  end

  def as_json(_opts = {})
    @applicant.as_json.merge(
      @rdv_solidarites_user.as_json
    )
  end
end
