module EnvironmentsHelper
  private

  def production_env?
    !staging_env? && !demo_env? && !local_env?
  end

  def staging_env?
    ENV["HOST"].include?("staging")
  end

  def demo_env?
    ENV["HOST"].include?("demo")
  end

  def local_env?
    Rails.env.development?
  end
end
