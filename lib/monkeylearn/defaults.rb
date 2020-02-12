module Monkeylearn
  module Defaults
    # Constants
    DEFAULT_BATCH_SIZE = 200
    MAX_BATCH_SIZE = 200
    # Configurable options
    BASE_URL = 'https://api.monkeylearn.com/v3/'
    RETRY_IF_THROTTLE = true
    AUTO_BATCH = true

    class << self
      def options
        Hash[Monkeylearn::Configurable.keys.map{|key| [key, send(key)]}]
      end

      def base_url
        ENV['MONKEYLEARN_API_BASE_URL'] || BASE_URL
      end

      def token
        ENV['MONKEYLEARN_TOKEN'] || nil
      end

      def retry_if_throttle
        boolean_setting('MONKEYLEARN_RETRY_IF_THROTTLE', RETRY_IF_THROTTLE)
      end

      def auto_batch
        boolean_setting('MONKEYLEARN_AUTO_BATCH', AUTO_BATCH)
      end

      def max_batch_size
        MAX_BATCH_SIZE
      end

      def default_batch_size
        DEFAULT_BATCH_SIZE
      end

      private

      def boolean_setting(key, default)
        return default unless ENV.key?(key)
        return !['nil', '', '0', 'off', 'false', 'f'].include?(ENV[key].to_s.downcase)
      end
    end
  end
end
