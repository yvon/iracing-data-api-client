require 'json'
require 'net/http'

class ResponseHandler
  def initialize(session, requester)
    @session = session
    @requester = requester
  end

  def handle_response(response)
    fail_on_error(response)
    @session.update_cookies(response)

    follow_link(response)
  end

  def fail_on_error(response)
    unless response.code.start_with?('2')
      raise <<~MSG
        Request failed.
          Status code: #{response.code}
          Body: #{response.body}
      MSG
    end
  end

  def follow_link(response)
    link = JSON.parse(response.body)['link']
    return response unless link

    request = Net::HTTP::Get.new(link)
    @requester.execute(URI(link), request)
  end
end
