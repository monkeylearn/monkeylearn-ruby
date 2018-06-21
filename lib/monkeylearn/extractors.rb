require 'monkeylearn/requests'
require 'monkeylearn/validators'

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

      def extract(module_id, data, options = {})
        batch_size = Monkeylearn::Validators.validate_batch_size(options[:batch_size])
        endpoint = build_endpoint(module_id, 'extract')

        if Monkeylearn.auto_batch
          responses = (0...data.length).step(batch_size).collect do |start_idx|
            sliced_data = {data: data.slice(start_idx, batch_size)}
            if options.key? :production_model
              sliced_data[:production_model] = options[:production_model]
            end
            request(:post, endpoint, data: sliced_data)
          end
          return Monkeylearn::MultiResponse.new(responses)
        else
          body = {data: data}
          if options.key? :production_model
              body[:production_model] = options[:production_model]
          end
          return request(:post, endpoint, data: body)
        end

      end

      def list(options = {})
        request(:get, build_endpoint, query_params: options)
      end

      def detail(module_id)
        request(:get, build_endpoint(module_id))
      end
    end
  end
end
