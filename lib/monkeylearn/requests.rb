require 'faraday'
require 'json'
require 'monkeylearn/response'

module Monkeylearn
  module Requests
    def request(method, path, data = nil, query_params = nil)
      unless Monkeylearn.token
        raise MonkeylearnError, 'Please initialize the Monkeylearn library with your API token'
      end

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
      if Monkeylearn.wait_on_throttle && seconds = throttled?(response)
        # Request was throttled, wait 'seconds' seconds and retry
        sleep seconds
        response = request(method, path, data)
      end
      Monkeylearn::Response.new(response)
    end

    def throttled?(response)
      return false if response.status != 429
      error_detail = JSON.parse(response.body)['detail']
      match = /available in ([\d]+) seconds/.match(error_detail)
       if match then match[1].to_i else false end
    end

    def get_connection
      @conn ||= Faraday.new(url: Monkeylearn.api_endpoint) do |faraday|
        faraday.adapter Faraday.default_adapter # Net::HTTP
      end
    end
  end
end
