class Session
  attr_accessor :cookies

  def initialize
    @cookies = []
  end

  def update_cookies(response)
    @cookies = response.get_fields('Set-Cookie')
  end
end
