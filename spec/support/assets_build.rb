# This hook checks that changes made to the js and css code are reflected in the compiled assets.
# If they are not we launch the build command.
RSpec.configure do |config|
  config.before(:suite) do
    # Skip asset building in CI environment
    if ENV["CI"]
      puts "CI environment detected; skipping asset build."
    # We only run this if feature specs are being run
    elsif config.files_to_run.any? { |file| file.include?("/spec/features/") }

      source_files = Dir[Rails.root.join("app/javascript/**/*.{js,jsx,css,scss,sass}")]

      built_assets = Dir[Rails.root.join("app/assets/builds/*.{js,css}")]

      source_last_modified = source_files.map { |f| File.mtime(f) }.max

      assets_last_modified = built_assets.map { |f| File.mtime(f) }.max

      if assets_last_modified.nil? || source_last_modified > assets_last_modified
        puts "Assets are not up-to-date; Building assets..."
        system("RAILS_ENV=test yarn build")
      end
    end
  end
end
