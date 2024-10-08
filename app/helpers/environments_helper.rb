module EnvironmentsHelper
  private

  def production_env?
    ENV["ENVIRONMENT_NAME"] == "production"
  end

  def staging_env?
    ENV["ENVIRONMENT_NAME"] == "staging"
  end

  def demo_env?
    ENV["ENVIRONMENT_NAME"] == "demo"
  end

  def development_env?
    Rails.env.development?
  end
end
