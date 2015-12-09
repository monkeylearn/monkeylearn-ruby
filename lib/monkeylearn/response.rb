module Monkeylearn
  class Response
    attr_reader :raw_response, :result, :query_limit_remaining

    def initialize(raw_response)
      self.raw_response = raw_response
    end

    def raw_response=(raw_response)
      @raw_response = raw_response
      @result = JSON.parse(raw_response.body)
      @query_limit_remaining = raw_response.headers['X-Query-Limit-Remaining'].to_i
    end
  end

  class MultiResponse
    attr_reader :responses, :result, :query_limit_remaining

    def initialize(responses)
      self.responses = responses
    end

    def responses=(responses)
      @responses = responses
      @query_limit_remaining = responses[-1].raw_response.headers['X-Query-Limit-Remaining'].to_i
      @result = responses.collect do |r|
        r.result['result']
      end.reduce(:+)
    end
  end
end
