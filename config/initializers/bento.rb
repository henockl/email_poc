Bento.configure do |config|
  # This is your site's UUID. This scopes all requests.
  # Consider creating a new site for each environment (development and production) in your Bento account.
  config.site_uuid = ENV["BENTO_SITE_UUID"]
  # This is your (or another user in your team's) API keys.
  # IMPORTANT: Never store these in your source code as they give full access to your Bento account.
  config.publishable_key = ENV["BENTO_PUBLISHABLE_KEY"]
  config.secret_key = ENV["BENTO_SECRET_KEY"]
end
