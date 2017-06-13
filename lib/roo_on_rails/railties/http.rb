module RooOnRails
  module Railties
    class HTTP < Rails::Railtie
      initializer 'roo_on_rails.http' do |app|
        $stderr.puts 'initializer roo_on_rails.http'
        require 'rack/timeout/base'
        require 'rack/ssl-enforcer'

        require 'roo_on_rails/rack/safe_timeouts'

        ::Rack::Timeout.service_timeout = ENV.fetch('RACK_SERVICE_TIMEOUT', 15).to_i
        ::Rack::Timeout.wait_timeout = ENV.fetch('RACK_WAIT_TIMEOUT', 30).to_i
        ::Rack::Timeout::Logger.level = Logger::WARN

        app.config.middleware.insert_before(
          ::Rack::Runtime,
          ::Rack::Timeout
        )

        # This needs to be inserted low in the stack, before Rails returns the
        # thread-current connection to the pool.
        app.config.middleware.insert_before(
          Rack::Head,
          RooOnRails::Rack::SafeTimeouts
        )

        if ENV.fetch('ROO_ON_RAILS_RACK_DEFLATE', 'YES').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
          app.config.middleware.use ::Rack::Deflater
        end

        # Don't use SslEnforcer in test environment as it breaks Capybara
        unless Rails.env.test?
          app.config.middleware.insert_before(
            Rack::Head,
            ::Rack::SslEnforcer
          )
        end
      end
    end
  end
end
