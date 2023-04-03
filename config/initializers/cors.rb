Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(/^(.*)rdv-insertion\.fr$/, /^(.*)rdv-insertion-demo\.fr$/)
    resource "*", headers: :any, methods: [:get, :post, :patch, :put]
  end
  allow do
    origins "*"
    resource "/inclusion_connect/auth", headers: :any, methods: [:get, :post, :patch, :put]
    resource "/inclusion_connect/callback", headers: :any, methods: [:get, :post, :patch, :put]
  end
end
