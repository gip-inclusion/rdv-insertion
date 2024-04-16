module ActsAsRdvSolidaritesConcern
  extend ActiveSupport::Concern

  included do
    default from: "rdv-solidarites <support-insertion@rdv-solidarites.fr>"
    layout "rdv_solidarites"

    helper_method :rdv_solidarites_invitations_url

    def rdv_solidarites_invitations_url(uuid)
      ENV["RDV_SOLIDARITES_URL"] + "/i/r/#{uuid}"
    end
  end
end
