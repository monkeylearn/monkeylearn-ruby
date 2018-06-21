require 'monkeylearn/requests'
require 'monkeylearn/validators'

module Monkeylearn
  class << self
    def classifiers
      return Classifiers
    end
  end

  module Classifiers
    class << self
      include Monkeylearn::Requests

      def tags
        return Tags
      end

      def build_endpoint(*args)
        File.join('classifiers', *args) + '/'
      end

      def classify(model_id, data, options = {})
        batch_size = Monkeylearn::Validators.validate_batch_size(options[:batch_size])
        api_version = Monkeylearn::Validators.validate_api_version(options[:api_version])
        endpoint = build_endpoint(model_id, 'classify')

        if Monkeylearn.auto_batch
          responses = (0...data.length).step(batch_size).collect do |start_idx|
            sliced_data = { data: data[start_idx, batch_size] }
            if options.key? :production_model
              sliced_data[:production_model] = options[:production_model]
            end
            request(:post, endpoint, data: sliced_data, api_version: api_version)
          end

          return Monkeylearn::MultiResponse.new(responses)
        else
          body = {data: data}
          if options.key? :production_model
              body[:production_model] = options[:production_model]
          end
          return request(:post, endpoint, data: body, api_version: api_version)
        end
      end

      def list(options = {})
        request(:get, build_endpoint, query_params: options)
      end

      def create(name, options = {})
        data = {
            name: name,
            description: options[:description],
            algorithm: options[:algorithm],
            language: options[:language],
            max_features: options[:max_features],
            ngram_range: options[:ngram_range],
            use_stemming: options[:use_stemming],
            preprocess_numbers: options[:preprocess_numbers],
            preprocess_social_media: options[:preprocess_social_media],
            normalize_weights: options[:normalize_weights],
            stopwords: options[:stopwords],
            whitelist: options[:whitelist],
        }.delete_if { |k,v| v.nil? }
        request(:post, build_endpoint, data: data)
      end

      def edit(module_id, options = {})
        data = {
            name: options[:name],
            description: options[:description],
            algorithm: options[:algorithm],
            language: options[:language],
            max_features: options[:max_features],
            ngram_range: options[:ngram_range],
            use_stemming: options[:use_stemming],
            preprocess_numbers: options[:preprocess_numbers],
            preprocess_social_media: options[:preprocess_social_media],
            normalize_weights: options[:normalize_weights],
            stopwords: options[:stopwords],
            whitelist: options[:whitelist],
        }.delete_if { |k,v| v.nil? }
        request(:patch, build_endpoint(module_id), data: data)
      end

      def detail(module_id)
        request(:get, build_endpoint(module_id))
      end

      def deploy(module_id)
        request(:post, build_endpoint(module_id, 'deploy'))
      end

      def upload_data(module_id, data)
        endpoint = build_endpoint(module_id, 'data')

        request(:post, endpoint, data: {data: data})
      end

      def delete(module_id)
        request(:delete, build_endpoint(module_id))
      end
    end
  end

  module Tags
    class << self
      include Monkeylearn::Requests

      def build_endpoint(module_id, *args)
        File.join('classifiers', module_id, 'tags', *args.collect { |x| x.to_s }) + '/'
      end

      def create(module_id, name, options = {})
        data = {
          name: name,
        }
        if options[:parent_id]
          data[:parent_id] = options[:parent_id]
        end
        request(:post, build_endpoint(module_id), data: data)
      end

      def detail(module_id, tag_id)
        request :get, build_endpoint(module_id, tag_id)
      end

      def edit(module_id, tag_id, options = {})
        endpoint = build_endpoint(module_id, tag_id)
        data = {
          name: options[:name],
          parent_id: options[:parent_id]
        }.delete_if { |k,v| v.nil? }
        request :patch, endpoint, data
      end

      def delete(module_id, tag_id, options = {})
        endpoint = build_endpoint(module_id, tag_id)

        data = nil
        if options.key?(:move_data_to)
          data = {move_data_to: options[:move_data_to]}
        end

        request(:delete, endpoint, data: data)
      end
    end
  end
end
