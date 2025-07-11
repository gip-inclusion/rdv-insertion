# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

s3_bucket = "rdv-insertion-medias-production.s3.fr-par.scw.cloud"
rdv_solidarites = ENV["RDV_SOLIDARITES_URL"]
matomo = "matomo.inclusion.beta.gouv.fr"
crisp = ["*.crisp.chat", "wss://client.relay.crisp.chat"]
sentry = "sentry.incubateur.net"
tally = "tally.so"
flourish = ["flo.uri.sh", "public.flourish.studio"] # for deployment map

Rails.application.config.content_security_policy do |policy|
  policy.default_src     :self
  policy.font_src        :self, :data, *crisp
  policy.img_src         :self, :data, s3_bucket, *crisp, *flourish, matomo
  policy.media_src       :self, s3_bucket
  policy.frame_src       :self, *flourish, tally
  policy.object_src      :none
  policy.script_src      :self, matomo, *crisp, *flourish, tally, sentry
  policy.style_src       :self, :unsafe_inline, *crisp
  policy.connect_src     :self, rdv_solidarites, sentry, matomo, tally, *crisp
  policy.form_action     :self, rdv_solidarites
  policy.frame_ancestors :self, rdv_solidarites, matomo
  policy.worker_src      :self, :blob
  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report"
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
