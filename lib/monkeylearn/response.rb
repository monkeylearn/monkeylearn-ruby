module Monkeylearn
  class Response
    attr_reader :raw_response, :status, :body, :plan_queries_allowed, :plan_queries_remaining, :request_queries_used

    def initialize(raw_response)
      self.raw_response = raw_response
    end

    def raw_response=(raw_response)
      @raw_response = raw_response
      @status = raw_response.status
      if raw_response.body != ''
        @body = JSON.parse(raw_response.body, symbolize_keys: true)
      else
        @body = nil
      end
      @plan_queries_allowed = @raw_response.headers['X-Query-Limit-Limit'].to_i
      @plan_queries_remaining = @raw_response.headers['X-Query-Limit-Remaining'].to_i
      @request_queries_used = @raw_response.headers['X-Query-Limit-Request-Queries'].to_i
    end
  end

  class MultiResponse
    attr_reader :responses, :body, :plan_queries_allowed, :plan_queries_remaining, :request_queries_used

    def initialize(responses)
      self.responses = responses
    end

    def body
      responses.collect do |r|
        r.body
      end.reduce(:+)
    end

    def responses=(responses)
      @responses = responses
      @query_limit_remaining = @responses[-1].raw_response.headers['X-Query-Limit-Remaining'].to_i
      @plan_queries_allowed = @responses[-1].plan_queries_allowed
      @plan_queries_remaining = @responses[-1].plan_queries_remaining
      @request_queries_used = @responses.inject(0){|sum, r| sum + r.request_queries_used }
    end
  end
end
