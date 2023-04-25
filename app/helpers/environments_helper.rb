module EnvironmentsHelper
  private

  def production_env?
    ENV["SENTRY_ENVIRONMENT"] == "production"
  end

  def staging_env?
    ENV["SENTRY_ENVIRONMENT"] == "staging"
  end
end
