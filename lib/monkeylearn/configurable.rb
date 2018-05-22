require 'monkeylearn/defaults'

module Monkeylearn
  module Configurable
    attr_accessor :token, :base_url, :retry_if_throttle, :auto_batch
    attr_writer :base_url

    class << self
      def keys
        @keys ||= [
          :base_url,
          :token,
          :retry_if_throttle,
          :auto_batch,
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

    def base_url
      File.join(@base_url, "")
    end
  end
end
