module EnvironmentsHelper
  def self.production_env?
    ENV["ENVIRONMENT_NAME"] == "production"
  end

  def self.staging_env?
    ENV["ENVIRONMENT_NAME"] == "staging"
  end

  def self.demo_env?
    ENV["ENVIRONMENT_NAME"] == "demo"
  end

  def self.development_env?
    Rails.env.development?
  end
end
