Rails.logger = Sidekiq.logger unless Rails.env.test?
