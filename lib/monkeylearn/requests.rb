require 'faraday'
require 'json'
require 'monkeylearn/response'
require 'monkeylearn/exceptions'

module Monkeylearn
  module Requests
    def request(method, path, data = nil, query_params = nil)
      unless Monkeylearn.token
        raise MonkeylearnError, 'Please initialize the Monkeylearn library with your API token'
      end

      while true
        response = get_connection.send(method) do |req|
          url = path.to_s
          if query_params
            url += '?' + URI.encode_www_form(query_params)
          end
          req.url url
          req.headers['Authorization'] = 'Token ' + Monkeylearn.token
          req.headers['Content-Type'] = 'application/json'
          req.headers['User-Agent'] = 'ruby-sdk'
          if data
            req.body = data.to_json
          end
        end

        seconds = throttled?(response)
        if seconds && Monkeylearn.retry_if_throttle
          sleep seconds
        else
          break
        end
      end

      if response.status != 200
        raise_for_status(response)
      end

      Monkeylearn::Response.new(response)
    end

    def raise_for_status(raw_response)
      body = JSON.parse(raw_response.body)
      error_code = body.fetch("error_code", nil)
      raise get_exception_class(raw_response.status, error_code).new(raw_response)
    end

    def get_exception_class(status_code, error_code)
      case status_code
      when 422
        return RequestParamsError
      when 401
        return AuthenticationError
      when 403
        case error_code
        when 'MODEL_LIMIT'
          return ModelLimitError
        else
          return ForbiddenError
        end
      when 404
        case error_code
        when 'MODEL_NOT_FOUND'
          return ModelNotFound
        when 'TAG_NOT_FOUND'
          return TagNotFound
        else
          return ResourceNotFound
        end
      when 429
        case error_code
        when 'PLAN_RATE_LIMIT'
          return PlanRateLimitError
        when 'CONCURRENCY_RATE_LIMIT'
          return ConcurrencyRateLimitError
        when 'PLAN_QUERY_LIMIT'
          return PlanQueryLimitError
        else
          return RateLimitError
        end
      when 423
        return ModuleStateError
      else
        return MonkeylearnResponseError
      end
    end

    def throttled?(response)
      return false unless response.status == 429
      body = JSON.parse(response.body)

      case body['error_code']
      when 'CONCURRENCY_RATE_LIMIT'
        seconds = 2
      when 'PLAN_RATE_LIMIT'
        match = /([\d]+) seconds/.match(body['detail'])
        seconds = if match then match[1].to_i else 60 end
      end
      seconds
    end

    def get_connection
      @conn ||= Faraday.new(url: Monkeylearn.base_url) do |faraday|
        faraday.adapter Faraday.default_adapter # Net::HTTP
      end
    end
  end
end
