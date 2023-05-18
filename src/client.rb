require 'json'

require_relative 'client/session'
require_relative 'client/rate_limiter'
require_relative 'client/requester'
require_relative 'client/authenticator'
require_relative 'client/response_handler'

class Client
  def initialize
    session = Session.new

    @rate_limiter = RateLimiter.new
    @requester = Requester.new(session)
    @authenticator = Authenticator.new(session, @requester)
    @response_handler = ResponseHandler.new(session, @requester)
  end

  def authenticate(email, password)
    @authenticator.authenticate(email, password)
  end

  def data(path)
    response = @rate_limiter.perform do
      puts "[%d] %s" % [@rate_limiter.remaining, path]
      @requester.get(path)
    end

    response = @response_handler.handle_response(response)

    JSON.parse(response.body)
  end
end
