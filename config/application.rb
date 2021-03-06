require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hs
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # config.i18n.default_locale = :ko
    config.i18n.default_locale = :ko
    config.time_zone = 'Seoul'

    ## Mailgun 이메일 설정
    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
        api_key: ENV['MAILGUN_API'],
        domain: ENV['MAILGUN_DOMAIN']
    }

    ## bit.ly 설정
    Bitly.use_api_version_3

    Bitly.configure do |config|
      config.api_version = 3
      config.access_token = ENV["BITLY_API"]
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
