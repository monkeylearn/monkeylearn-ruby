module Monkeylearn
  module Validators
    class << self
      def validate_batch_size(size)
        size ||= Monkeylearn::Defaults.default_batch_size
        max_size = Monkeylearn::Defaults.max_batch_size
        if size > max_size
          raise MonkeylearnError, "The param batch_size is too big, max value is #{max_size}."
        end
        size
      end

      def validate_api_version(version)
        version ||= Monkeylearn::Defaults.api_version
        supported_versions = Monkeylearn::Defaults.supported_api_versions
        unless supported_versions.include? version
          raise MonkeylearnError, "The param api_version `#{version}` is not supported, choose from #{supported_versions.join(', ')}."
        end
        version
      end
    end
  end
end
