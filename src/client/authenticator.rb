require 'net/http'
require 'digest'

class Authenticator
  PATH = "/auth"

  def initialize(session, requester)
    @session = session
    @requester = requester
  end

  def authenticate(email, password)
    request = create_request(email, password)
    response = @requester.execute(PATH, request)

    unless response.code.start_with?('2')
      raise "Authentication failed. Status code: #{response.code}"
    end

    puts 'Successfully connected!'
    @session.update_cookies(response)
  end

  private

  def create_request(email, password)
    hashed_password = Digest::SHA256.base64digest("#{password}#{email.downcase}")
    data = { "email" => email, "password" => hashed_password }.to_json

    request = Net::HTTP::Post.new(PATH, {'Content-Type' => 'application/json'})
    request.body = data
    request
  end
end
