require 'json'

class MonkeylearnError < StandardError
end

class MonkeylearnResponseError < MonkeylearnError
  def initialize(raw_response)
    @response = raw_response


    body = JSON.parse(raw_response.body)
    @detail = body['detail']
    @error_code = body['error_code']
    @status_code = raw_response.status


    super "#{@error_code}: #{@detail}"
  end
end

# Request Validation Errors (422)

class RequestParamsError < MonkeylearnResponseError
end

# Authentication (401)


class AuthenticationError < MonkeylearnResponseError
end

# Forbidden  (403)

class ForbiddenError < MonkeylearnResponseError
end


class ModelLimitError < ForbiddenError
end

# Not found Exceptions (404)

class ResourceNotFound < MonkeylearnResponseError
end


class ModelNotFound < ResourceNotFound
end


class TagNotFound < ResourceNotFound
end

# Rate limit  (429)

class RateLimitError < MonkeylearnResponseError
end


class PlanQueryLimitError < MonkeylearnResponseError
end


class PlanRateLimitError < RateLimitError
end


class ConcurrencyRateLimitError < RateLimitError
end

# State errors  < 423)

class ModuleStateError < MonkeylearnResponseError
end
