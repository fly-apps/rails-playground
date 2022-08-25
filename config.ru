# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

require_relative 'lib/hijacker'

# Turn on the optional logging feature
use Rack::Logger

use Hijacker

run Rails.application
Rails.application.load_server
