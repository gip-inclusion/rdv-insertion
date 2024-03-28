module ActsAsRdvSolidaritesConcern
  extend ActiveSupport::Concern

  included do
    after_action :rewrite_external_urls

    default from: "rdv-solidarites <support.rdv-insertion@rdv-solidarites.fr>"
    layout "rdv_solidarites"
  end

  def rewrite_external_urls
    # We change all non assets URLs in favor of Rdvs redirection URL
    @_message.body.raw_source.gsub!(/#{Regexp.escape(ENV['HOST'])}(?!\/assets)/, ENV["RDV_SOLIDARITES_URL"] + "/rdvi")
  end

  # def mail(**params)
  #   params.merge!(delivery_method_options: {
  #     address: "smtp-relay.sendinblue.com",
  #     port: "587",
  #     authentication: "login",
  #     enable_starttls_auto: true,
  #     user_name: ENV["BREVO_RDVS_USERNAME"],
  #     password: ENV["BREVO_RDVS_PASSWORD"],
  #     domain: "rdv-solidarites.fr"
  #   })

  #   super(params)
  # end
end
