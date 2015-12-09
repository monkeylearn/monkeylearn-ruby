require 'monkeylearn/defaults'

module Monkeylearn
  module Configurable
    attr_accessor :token, :api_endpoint
    attr_writer :api_endpoint

    class << self
      def keys
        @keys ||= [
          :api_endpoint,
          :token,
          :wait_on_throttle
        ]
      end
    end

    def configure
      yield self
    end

    def reset!
      Monkeylearn::Configurable.keys.each do |key|
        instance_variable_set(:"@#{key}", Monkeylearn::Defaults.options[key])
      end
      self
    end

    def wait_on_throttle
      @wait_on_throttle
    end

    def api_endpoint
      File.join(@api_endpoint, "")
    end
  end
end
