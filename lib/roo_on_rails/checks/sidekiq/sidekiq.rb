require 'roo_on_rails/checks/base'
require 'thor'

module RooOnRails
  module Checks
    module Sidekiq
      class Sidekiq < Base
        WORKER_PROCFILE_LINE = 'worker: bundle exec roo_on_rails sidekiq'.freeze

        def intro
          'Checking Sidekiq Setup...'
        end

        def call
          unless ENV.fetch('SIDEKIQ_ENABLED', 'true').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
            pass 'SIDEKIQ_ENABLED is set to false'
            return
          end
          check_for_procfile
        end

        def fix
          if File.exist?('Procfile')
            append_to_file 'Procfile', "\n#{WORKER_PROCFILE_LINE}"
          else
            create_file 'Procfile', WORKER_PROCFILE_LINE
          end
        end

        def check_for_procfile
          return if File.exist?('Procfile') && File.read('Procfile').include?('worker')
          fail! "No Procfile found with a 'worker' command"
        end
      end
    end
  end
end
