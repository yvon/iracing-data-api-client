class DataFetcher
  def initialize(client, storage_directory = '.')
    @client = client
    @storage_directory = storage_directory
  end

  def data(url)
    case url
    when %r{^/data/results/get} then fetch_if_nonexistent(url)
    when %r{^/data} then fetch_and_store(url)
    else raise "Unexpected url: #{url}"
    end
  end

  private

  def fetch_and_store(url)
    response = @client.get(url)

    # Ensure we can parse the response before writing it to disk
    parsed_response = JSON.parse(response.body)

    # Cache the response
    file_path = file_path(url)
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, response.body)

    parsed_response
  end

  def fetch_if_nonexistent(url)
    return if File.exist?(file_path(url))

    fetch_and_store(url)
  end

  def file_path(url)
    File.join(@storage_directory, url)
  end
end
