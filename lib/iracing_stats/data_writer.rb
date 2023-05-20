module IracingStats
  class DataWriter
    def initialize(client, storage_directory = '.')
      @client = client
      @storage_directory = storage_directory
    end

    def fetch_and_store(filename)
      url = "/#{filename}"
      response = @client.get(url)

      # Ensure we can parse the response before writing it to disk
      parsed_response = JSON.parse(response.body)

      # Store the response
      file_path = File.join(@storage_directory, filename)
      FileUtils.mkdir_p(File.dirname(file_path))
      File.write(file_path, response.body)

      parsed_response
    end
  end
end
