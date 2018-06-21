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
    end
  end
end
