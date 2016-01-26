require 'monkeylearn/requests'

module Monkeylearn
  class << self
    def classifiers
      return Classifiers
    end
  end

  module Classifiers
    class << self
      include Monkeylearn::Requests

      def categories
        return Categories
      end

      def build_endpoint(*args)
        File.join('classifiers', *args) + '/'
      end

      def validate_batch_size(batch_size)
        max_size = Monkeylearn::Defaults.max_batch_size
        if batch_size >  max_size
          raise MonkeylearnError, "The param batch_size is too big, max value is #{max_size}."
        end
        min_size = Monkeylearn::Defaults.min_batch_size
        if batch_size <  min_size
          raise MonkeylearnError, "The param batch_size is too small, min value is #{min_size}."
        end
        true
      end

      def classify(module_id, texts, options = {})
        options[:batch_size] ||= Monkeylearn::Defaults.default_batch_size
        batch_size = options[:batch_size]
        validate_batch_size batch_size

        endpoint = build_endpoint(module_id, 'classify')
        query_params = { sandbox: true } if options[:sandbox]

        responses = (0...texts.length).step(batch_size).collect do |start_idx|
          data = { text_list: texts.slice(start_idx, batch_size) }
          response = request :post, endpoint, data, query_params
        end

        Monkeylearn::MultiResponse.new(responses)
      end

      def create(name, options = {})
        data = {
            name: name,
            description: options[:description],
            language: options[:language],
            ngram_range: options[:ngram_range],
            use_stemmer: options[:use_stemmer],
            stop_words: options[:stop_words],
            max_features: options[:max_features],
            strip_stopwords: options[:strip_stopwords],
            is_multilabel: options[:is_multilabel],
            is_twitter_data: options[:is_twitter_data],
            normalize_weights: options[:normalize_weights],
            classifier: options[:classifier],
            industry: options[:industry],
            classifier_type: options[:classifier_type],
            text_type: options[:text_type],
            permissions: options[:permissions]
        }.delete_if { |k,v| v.nil? }
        request :post, build_endpoint, data
      end

      def detail(module_id)
        request :get, build_endpoint(module_id)
      end

      def upload_samples(module_id, samples_with_categories)
        unless samples_with_categories.respond_to? :each
          raise MonkeylearnError, "The second param must be an enumerable type (i.e. an Array)."
        end
        endpoint = build_endpoint(module_id, 'samples')
        data = {
          samples: samples_with_categories.collect do |text, category_ids|
            {text: text, category_id: category_ids}
          end
        }
        request :post, endpoint, data
      end

      def train(module_id)
        request :post, build_endpoint(module_id, 'train')
      end

      def deploy(module_id)
        request :post, build_endpoint(module_id, 'deploy')
      end

      def delete(module_id)
        request :delete, build_endpoint(module_id)
      end
    end
  end

  module Categories
    class << self
      include Monkeylearn::Requests

      def build_endpoint(module_id, *args)
        File.join('classifiers', module_id, 'categories', *args.collect { |x| x.to_s }) + '/'
      end

      def create(module_id, name, parent_id)
        data = {
          name: name,
          parent_id: parent_id
        }
        request :post, build_endpoint(module_id), data
      end

      def edit(module_id, category_id, name = nil, parent_id = nil)
        endpoint = build_endpoint(module_id, category_id)
        data = {
          name: name,
          parent_id: parent_id
        }.delete_if { |k,v| v.nil? }
        request :patch, endpoint, data
      end

      def delete(module_id, category_id, samples_strategy = nil, samples_category_id = nil)
        endpoint = build_endpoint(module_id, category_id)
        data = {
          'samples-strategy'.to_s => samples_strategy,
          'samples-category-id'.to_s => samples_category_id
        }.delete_if { |k,v| v.nil? }
        request :delete, endpoint, data
      end
    end
  end
end
