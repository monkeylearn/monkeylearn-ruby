require 'monkeylearn/requests'

module Monkeylearn
  class << self
    def extractors
      return Extractors
    end
  end

  module Extractors
    class << self
      include Monkeylearn::Requests

      def build_endpoint(*args)
        File.join('extractors', *args) + '/'
      end

      def validate_batch_size(batch_size)
        max_size = Monkeylearn::Defaults.max_batch_size
        if batch_size >  max_size
          raise MonkeylearnError, "The param batch_size is too big, max value is #{max_size}."
        end
        true
      end

      def extract(module_id, texts, options = {})
        options[:batch_size] ||= Monkeylearn::Defaults.default_batch_size
        batch_size = options[:batch_size]
        validate_batch_size batch_size

        endpoint = build_endpoint(module_id, 'extract')

        responses = (0...texts.length).step(batch_size).collect do |start_idx|
          data = {data: texts.slice(start_idx, batch_size)}
          request(:post, endpoint, data)
        end

        Monkeylearn::MultiResponse.new(responses)
      end

      def list(options = {})
        request(:get, build_endpoint, nil, options)
      end

      def detail(module_id)
        request(:get, build_endpoint(module_id))
      end
    end
  end
end
