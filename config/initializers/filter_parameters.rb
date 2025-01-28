# Insipred by https://docs.appsignal.com/guides/filter-data/filter-parameters.html
# We set an allow-list through a REGEX instead of a deny-list to be safer on the data we log
ALLOWED_PARAMETERS_IN_LOGS_REGEX = /
  ((^|_)u?ids?|action|controller|timestamp|role|^event$|
  (created|updated|deleted|expires|starts)_at$|
  through$|date$|type$|status$|collectif$|role$|created_by$|model$|webhook_reason$)
  /x

SANITIZED_VALUE = "[FILTERED]".freeze

unless Rails.env.development?
  Rails.application.config.filter_parameters << lambda do |key, value|
    value.replace(SANITIZED_VALUE) if !key.match(ALLOWED_PARAMETERS_IN_LOGS_REGEX) && value.is_a?(String)
  end
end
