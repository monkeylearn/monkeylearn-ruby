require 'monkeylearn/requests'
require 'monkeylearn/param_validation'

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

      def extract(module_id, data, options = {})
        options[:batch_size] ||= Monkeylearn::Defaults.default_batch_size
        batch_size = options[:batch_size]
        validate_batch_size batch_size

        endpoint = build_endpoint(module_id, 'extract')

        if Monkeylearn.auto_batch
          responses = (0...data.length).step(batch_size).collect do |start_idx|
            sliced_data = {data: data.slice(start_idx, batch_size)}
            if options.key? :production_model
              sliced_data[:production_model] = options[:production_model]
            end
            request(:post, endpoint, sliced_data)
          end
          return Monkeylearn::MultiResponse.new(responses)
        else
          body = {data: data}
          if options.key? :production_model
              body[:production_model] = options[:production_model]
          end
          return request(:post, endpoint, body)
        end

      end

      def list(options = {})
        if options.key?(:order_by)
          options[:order_by] = validate_order_by_param(options[:order_by])
        end
        query_params = {
          page: options[:page],
          per_page: options[:per_page],
          order_by: options[:order_by]
        }.delete_if { |k,v| v.nil? }
        request(:get, build_endpoint, nil, query_params)
      end

      def detail(module_id)
        request(:get, build_endpoint(module_id))
      end
    end
  end
end
