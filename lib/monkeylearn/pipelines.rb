require 'monkeylearn/requests'

module Monkeylearn
  class << self
    def pipelines
      return Pipelines
    end
  end

  module Pipelines
    class << self
      include Monkeylearn::Requests

      def build_endpoint(*args)
        File.join('pipelines', *args) + '/'
      end

      def run(module_id, data, options = {})
        query_params = { sandbox: true } if options[:sandbox]
        endpoint = build_endpoint(module_id, 'run')
        unless data.is_a?(Hash)
          raise MonkeylearnError, 'The data param must be a hash'
        end
        request :post, endpoint, data
      end
    end
  end
end
