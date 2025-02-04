# Insipred by https://docs.appsignal.com/guides/filter-data/filter-parameters.html
# We set an allow-list through a REGEX instead of a deny-list to be safer on the data we log
ALLOWED_PARAMETERS_IN_LOGS_REGEX = /
  ((^|_)u?ids?|action|controller|timestamp|role|^event$|
  (created|updated|deleted|expires|starts|received)_at$|
  through$|date$|type$|status$|collectif$|role$|created_by$|model$|webhook_reason$)
  /x

SANITIZED_VALUE = "[FILTERED]".freeze

CUSTOM_PARAMETER_FILTER = lambda do |key, value|
  value.replace(SANITIZED_VALUE) if !key.match(ALLOWED_PARAMETERS_IN_LOGS_REGEX) && value.is_a?(String)
end

Rails.application.config.after_initialize do
  # we don't filter the logs in dev and staging
  if EnvironmentsHelper.production_env? || EnvironmentsHelper.demo_env? || Rails.env.test?
    Rails.application.config.filter_parameters << CUSTOM_PARAMETER_FILTER
    # We need to remove the CUSTOM_PARAMETER_FILTER from the filter_attributes of AR classes
    # because it is inconvenient for support/debug to have all the AR records
    # displayed with [FILTERED] in the production rails console
    ActiveRecord::Base.filter_attributes -= [CUSTOM_PARAMETER_FILTER]
  end
end
