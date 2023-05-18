require_relative 'file_cache'

class ResultFetcher
  def initialize(client)
    @client = client
    @cache = FileCache.new('results')
  end

  def fetch(subsession_id)
    path = "/data/results/get?subsession_id=#{subsession_id}"
    @cache.fetch(subsession_id) { @client.data(path) }
  end
end
