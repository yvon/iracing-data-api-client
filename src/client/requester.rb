require 'net/http'

class Requester
  HOST = 'members-ng.iracing.com'
  BASE_URI = URI::HTTPS.build(host: HOST)

  def initialize(session)
    @session = session
  end

  def get(uri_or_path)
    request = Net::HTTP::Get.new(uri_or_path)
    execute(uri_or_path, request)
  end

  def execute(uri_or_path, request)
    uri = normalize_uri(uri_or_path)
    add_cookies_to_request(request, uri)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end
  
  private

  def add_cookies_to_request(request, uri)
    if uri.host == HOST && @session.cookies
      request['Cookie'] = @session.cookies.join('; ')
    end
  end

  def normalize_uri(uri_or_path)
    return uri_or_path if uri_or_path.is_a?(URI)

    URI.join(BASE_URI, uri_or_path)
  end
end
