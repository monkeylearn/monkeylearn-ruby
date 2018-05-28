require 'monkeylearn/configurable'
require 'monkeylearn/exceptions'
require 'monkeylearn/classifiers'
require 'monkeylearn/extractors'


module Monkeylearn
  class << self
    include Monkeylearn::Configurable
  end
end

Monkeylearn.reset!
