module ActsAsRdvSolidaritesConcern
  extend ActiveSupport::Concern

  included do
    default from: "rdv-solidarites <support-insertion@rdv-solidarites.fr>"
    layout "rdv_solidarites"

    helper RdvSolidaritesMailerHelper
  end
end
