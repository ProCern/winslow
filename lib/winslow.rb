require 'winslow/engine'

module Winslow
  class Configuration
    attr_accessor :resource_lookup
  end

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
