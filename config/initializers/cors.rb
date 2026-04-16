Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Development: allow React Native metro bundler + simulators
    origins ENV.fetch("ALLOWED_ORIGINS", "*")

    resource "/api/*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose:  %w[Authorization]
  end
end
