require 'monkeylearn/requests'
require 'monkeylearn/param_validation'

module Monkeylearn
  class << self
    def workflows
      return Workflows
    end
  end

  module Workflows
    class << self
      include Monkeylearn::Requests

      def steps
        return WorkflowSteps
      end

      def data
        return WorkflowData
      end

      def metadata
        return WorkflowMetadata
      end

      def build_endpoint(*args)
        File.join('workflows', *args) + '/'
      end

      def create(name, options = {})
        data = {
            name: name,
            description: options[:description],
            db_name: options[:db_name],
            webhook_url: options[:webhook_url],
            steps: options[:steps],
            metadata: options[:metadata],
            sources: options[:sources],
            actions: options[:actions],
        }.delete_if { |k,v| v.nil? }
        request(:post, build_endpoint, data)
      end

      def detail(module_id)
        request(:get, build_endpoint(module_id))
      end

      def delete(module_id)
        request(:delete, build_endpoint(module_id))
      end
    end
  end

  module WorkflowSteps
    class << self
      include Monkeylearn::Requests

      def build_endpoint(module_id, *args)
        File.join('workflows', module_id, 'steps', *args.collect { |x| x.to_s }) + '/'
      end

      def create(module_id, options = {})
        data = {
            name: options[:name],
            model_id: options[:step_model_id],
            input_step: options[:input_step],
            conditions: options[:conditions],
        }.delete_if { |k,v| v.nil? }
        request(:post, build_endpoint(module_id), data)
      end
    end
  end

  module WorkflowMetadata
    class << self
     include Monkeylearn::Requests

      def build_endpoint(module_id, *args)
        File.join('workflows', module_id, 'metadata', *args.collect { |x| x.to_s }) + '/'
      end

      def create(module_id, options = {})
        data = {
            name: options[:name],
            type: options[:data_type],
        }.delete_if { |k,v| v.nil? }
        request(:post, build_endpoint(module_id), data)
      end
    end
  end

  module WorkflowData
    class << self
     include Monkeylearn::Requests

      def build_endpoint(module_id, *args)
        File.join('workflows', module_id, 'data', *args.collect { |x| x.to_s }) + '/'
      end

      def create(module_id, options = {})
        data = {
            data: options[:data],
        }.delete_if { |k,v| v.nil? }
        request(:post, build_endpoint(module_id), data)
      end

      def list(module_id, options = {})
        query_params = {
          batch_id: options[:batch_id],
          is_processed: options[:is_processed],
          sent_to_process_date_from: options[:sent_to_process_date_from],
          sent_to_process_date_to: options[:sent_to_process_date_to],
          page: options[:page],
          per_page: options[:per_page],
        }.delete_if { |k,v| v.nil? }

        request(:get, build_endpoint(module_id), nil, query_params)
      end
    end
  end
end
