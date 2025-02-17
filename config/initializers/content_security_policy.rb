# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

s3_bucket = "rdv-insertion-medias-production.s3.fr-par.scw.cloud"
rdv_solidarites = ENV["RDV_SOLIDARITES_URL"]
matomo = "matomo.inclusion.beta.gouv.fr"
crisp = ["*.crisp.chat", "wss://client.relay.crisp.chat"]
sentry = "sentry.incubateur.net"
maze = "*.maze.co"
flourish = "flo.uri.sh" # for deployment map

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data, s3_bucket
  policy.media_src :self, s3_bucket
  policy.frame_src :self, flourish, maze
  policy.object_src  :none
  policy.script_src  :self, :https, :unsafe_inline
  policy.style_src   :self, :https, :unsafe_inline
  policy.connect_src :self, rdv_solidarites, sentry, matomo, maze, *crisp
  policy.worker_src :self, :blob
  # Specify URI for violation reports
  # policy.report_uri "/csp-violation-report-endpoint"
end

# If you are using UJS then enable automatic nonce generation
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
