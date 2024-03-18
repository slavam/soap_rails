Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://10.54.1.32:8650'
    resource '*', headers: :any, methods: [:get, :post]
  end
end