module IracingStats
  class DataReader
    def initialize(storage_directory = '.')
      @storage_directory = storage_directory
    end

    def data(url)
      read_and_parse(url)
    end

    private

    def read_and_parse(url)
      file_path = File.join(@storage_directory, url)
      raise "File not found: #{file_path}" unless File.exist?(file_path)

      json_content = File.read(file_path)
      JSON.parse(json_content)
    end
  end
end
